#!/bin/bash
# WPA-WemxInstall.sh - Automated WemX Installation Script

# Set up error handling
set -e

# Color definitions
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

# Logging functions
success() { echo -e "* ${COLOR_GREEN}SUCCESS${COLOR_NC}: $1" 1>&2; }
error() { echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1" 1>&2; }
warning() { echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1" 1>&2; }
notice() { echo -e "* ${COLOR_BLUE}NOTICE${COLOR_NC}: $1" 1>&2; }

# Function to handle errors
handle_error() {
    error "An error occurred during installation at line $1"
    if [ -f "$progress_file" ]; then
        error "Installation failed at step $(cat $progress_file)"
    fi
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Configuration
INSTALL_DIR="/var/www/wemx"
progress_file="/tmp/wemx_install_progress"

# Check if secrets file exists and read database credentials
check_database_credentials() {
    if [ ! -f "/root/WPA-ToolBox/database/CatSecrets.txt" ]; then
        error "Database credentials file not found. Please run database setup first."
        exit 1
    fi
    
    # Read database credentials
    DB_USER=$(grep "WemX User:" /root/WPA-ToolBox/database/CatSecrets.txt | cut -d' ' -f3)
    DB_PASS=$(grep "WemX Password:" /root/WPA-ToolBox/database/CatSecrets.txt | cut -d' ' -f3)
    
    if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
        error "Database credentials not found in secrets file."
        exit 1
    fi
}

# Function to get database credentials from CatSecrets.txt
get_database_credentials() {
    local secrets_file="/root/WPA-ToolBox/database/CatSecrets.txt"
    
    if [ ! -f "$secrets_file" ]; then
        error "CatSecrets.txt not found at $secrets_file"
        exit 1
    fi
    
    # Read the entire file content for debugging
    notice "Reading CatSecrets.txt content..."
    cat "$secrets_file"
    
    # Get credentials with more robust parsing
    DB_HOST=$(grep -i "Access Host:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_USER=$(grep -i "WemX User:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_PASS=$(grep -i "WemX Password:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_NAME=$(grep -i "WemX Database:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    
    # Trim any potential whitespace
    DB_HOST=$(echo "$DB_HOST" | xargs)
    DB_USER=$(echo "$DB_USER" | xargs)
    DB_PASS=$(echo "$DB_PASS" | xargs)
    DB_NAME=$(echo "$DB_NAME" | xargs)
    
    # Verify each credential
    notice "Verifying credentials..."
    notice "Host: $DB_HOST"
    notice "User: $DB_USER"
    notice "Database: $DB_NAME"
    notice "Password length: ${#DB_PASS}"
    
    if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; then
        error "Could not find complete database credentials in CatSecrets.txt"
        error "Host: ${DB_HOST:-MISSING}"
        error "User: ${DB_USER:-MISSING}"
        error "Pass: ${DB_PASS:-MISSING}"
        error "Name: ${DB_NAME:-MISSING}"
        exit 1
    fi
}

# Function to check if composer is installed
check_composer() {
    if ! command -v composer &> /dev/null; then
        notice "Composer not found. Installing composer..."
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    fi
}

# Create Laravel project
create_laravel_project() {
    notice "Creating new Laravel project..."
    cd /var/www
    
    # Remove existing directory if it exists
    if [ -d "$INSTALL_DIR" ]; then
        warning "Existing WemX installation found. Creating backup..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    COMPOSER_ALLOW_SUPERUSER=1 composer create-project laravel/laravel wemx
    success "Laravel project created successfully"
}

# Setup fresh environment
setup_fresh_env() {
    # Get database credentials from CatSecrets.txt
    notice "Reading database credentials from CatSecrets.txt..."
    get_database_credentials
    
    notice "Retrieved database password: ${DB_PASS}"
    if [ -z "${DB_PASS}" ]; then
        error "Database password is empty after reading from CatSecrets.txt"
        exit 1
    fi
    
    # Copy example env from WemX
    if [ ! -f ".env.example" ]; then
        error "No .env.example file found after WemX installation. This shouldn't happen."
        exit 1
    fi
    
    cp .env.example .env
    
    # Create a temporary file with all our environment configurations
    cat > .env.tmp << EOF
APP_NAME=WemX
APP_URL=https://${APP_DOMAIN}
DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}
APP_ENV=production
APP_DEBUG=false
EOF

    # Merge the temporary file with the original .env, preferring our values
    while IFS= read -r line; do
        key=$(echo "$line" | cut -d'=' -f1)
        if grep -q "^${key}=" .env; then
            sed -i "s|^${key}=.*|${line}|" .env
        else
            echo "$line" >> .env
        fi
    done < .env.tmp
    
    rm .env.tmp
    
    # Double check the password was set
    DB_PASSWORD_SET=$(grep "^DB_PASSWORD=" .env | cut -d'=' -f2)
    notice "Verifying database password... Current value: ${DB_PASSWORD_SET}"
    
    if [ "$DB_PASSWORD_SET" != "$DB_PASS" ]; then
        warning "Password not set correctly through merge. Using direct method..."
        sed -i '/^DB_PASSWORD=/d' .env
        echo "DB_PASSWORD=${DB_PASS}" >> .env
    fi
    
    # Generate application key only for fresh installations
    notice "Generating application key..."
    php artisan key:generate --force
}

# Configure environment
configure_environment() {
    cd "$INSTALL_DIR"
    
    # Ask for domain first
    notice "Please enter your WemX authorized domain"
    notice "This will be used as your Application URL"
    read -p "Authorized WemX Domain (e.g., nekohosting.gg): " APP_DOMAIN
    
    if [ -z "$APP_DOMAIN" ]; then
        error "Domain cannot be empty"
        configure_environment
        return
    fi
    
    # Get current date for backup naming
    backup_date=$(date "+%Y%m%d_%H%M%S")
    
    if [ -f ".env" ]; then
        notice "Existing .env file detected!"
        
        # Check if it appears to be a valid .env file
        if grep -q "^APP_KEY=" .env; then
            warning "Found existing APP_KEY in .env file"
            notice "Creating backup of existing .env file as .env.backup_${backup_date}"
            cp .env ".env.backup_${backup_date}"
			# Fail Safe, Just in case you ran this twice for whatever reason.
			cp .env .env.old_$date
			cp .env.example .env
            notice "Preserving existing .env configuration"
            # Update only the domain in existing .env
            sed -i "s#APP_URL=.*#APP_URL=https://${APP_DOMAIN}#g" .env
        else
            warning "Existing .env file found but appears incomplete"
            notice "Creating backup of existing .env as .env.incomplete_${backup_date}"
            cp .env ".env.incomplete_${backup_date}"
			# Fail Safe, Just in case you ran this twice for whatever reason.
			cp .env .env.old_$date
			cp .env.example .env
            setup_fresh_env
        fi
    else
        notice "No existing .env file found. Setting up fresh environment..."
        setup_fresh_env
    fi
    
    COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader
}

# Install WemX
install_wemx() {
    cd "$INSTALL_DIR"
    
    notice "Removing default Laravel migrations..."
    rm -rf database/migrations/*
    
    notice "Installing WemX via composer..."
    COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-web
    
    notice "Please enter your WemX license key:"
    read -r LICENSE_KEY
    
    notice "Installing WemX..."
    php artisan wemx:install "$LICENSE_KEY"
    
    # At this point, WemX should have created its own .env.example
}

# Enable modules and set up storage
setup_modules() {
    cd "$INSTALL_DIR"
    
    notice "Enabling modules..."
    php artisan module:enable
    
    notice "Creating storage link..."
    php artisan storage:link
    
    notice "Running database migrations..."
    php artisan migrate --force
    
    notice "Updating license key..."
    php artisan license:update
    
    # Clear various caches to ensure clean state
    notice "Clearing application caches..."
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
}

# Set permissions and create cron job
finalize_installation() {
    notice "Setting correct permissions..."
    chown -R www-data:www-data "$INSTALL_DIR"/*
    
    notice "Setting up cron job..."
    (crontab -l 2>/dev/null; echo "* * * * * php $INSTALL_DIR/artisan schedule:run >> /dev/null 2>&1") | crontab -
}

# Main installation function
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox WemX Installation"
    echo "============================================================================"
    
    # Initialize progress tracking
    echo "0" > "$progress_file"
    
    check_composer
    echo "1" > "$progress_file"
    
    check_database_credentials
    echo "2" > "$progress_file"
    
    create_laravel_project
    echo "3" > "$progress_file"
    
    install_wemx
    echo "4" > "$progress_file"=
    
    configure_environment
    echo "5" > "$progress_file"
    
	setup_fresh_env
    echo "6" > "$progress_file"
	
    setup_modules
    echo "7" > "$progress_file"
    
    finalize_installation
    echo "8" > "$progress_file"
    
    # Cleanup
    rm -f "$progress_file"
    
    success "WemX installation completed successfully!"
    notice "You can now access your WemX installation through your configured domain."
}

# Execute main installation
main "$@"