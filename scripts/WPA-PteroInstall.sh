#!/bin/bash
# WPA-PteroInstall.sh - Automated Pterodactyl Panel Installation Script

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
INSTALL_DIR="/var/www/pterodactyl"
progress_file="/tmp/ptero_install_progress"

# Function to get database credentials from CatSecrets.txt
get_database_credentials() {
    local secrets_file="/root/WPA-ToolBox/database/CatSecrets.txt"
    
    if [ ! -f "$secrets_file" ]; then
        error "CatSecrets.txt not found at $secrets_file"
        exit 1
    fi
    
    # Read credentials
    DB_HOST=$(grep -i "Access Host:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_USER=$(grep -i "Pterodactyl User:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_PASS=$(grep -i "Pterodactyl Password:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    DB_NAME=$(grep -i "Pterodactyl Database:" "$secrets_file" | tail -1 | sed 's/.*: *//')
    
    # Trim whitespace
    DB_HOST=$(echo "$DB_HOST" | xargs)
    DB_USER=$(echo "$DB_USER" | xargs)
    DB_PASS=$(echo "$DB_PASS" | xargs)
    DB_NAME=$(echo "$DB_NAME" | xargs)
    
    # Verify credentials
    if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; then
        error "Could not find complete database credentials in CatSecrets.txt"
        exit 1
    fi
}

# Download and extract Pterodactyl files
download_pterodactyl() {
    notice "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Clean existing files if present
    if [ -f "panel.tar.gz" ]; then
        rm panel.tar.gz
    fi
    
    # Remove existing files except .env if it exists
    if [ -d "$INSTALL_DIR" ]; then
        find "$INSTALL_DIR" -mindepth 1 ! -name '.env' -exec rm -rf {} +
    fi
    
    notice "Downloading latest Pterodactyl panel..."
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
}

# Configure environment
configure_environment() {
    cd "$INSTALL_DIR"
    
    notice "Installing composer dependencies first..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    
    if [ ! -f "vendor/autoload.php" ]; then
        error "Composer installation failed - autoload.php not found"
        exit 1
    fi
    
    notice "Please enter your Pterodactyl panel domain"
    read -p "Domain (e.g., panel.yourdomain.com): " APP_DOMAIN
    
    if [ -z "$APP_DOMAIN" ]; then
        error "Domain cannot be empty"
        configure_environment
        return
    fi
    
    # Get database credentials
    get_database_credentials
    
    # Create environment file
    cp .env.example .env
    
    # Configure environment file
    sed -i "s|APP_URL=.*|APP_URL=https://${APP_DOMAIN}|g" .env
    sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=UTC|g" .env
    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|g" .env
    sed -i "s|DB_PORT=.*|DB_PORT=3306|g" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
    
    # Generate application key
    php artisan key:generate --force
}

# Install dependencies and setup database
setup_database() {
    cd "$INSTALL_DIR"
    
    notice "Installing composer dependencies..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    
    notice "Setting up database..."
    php artisan migrate --seed --force
}

# Configure mail settings
configure_mail() {
    cd "$INSTALL_DIR"
    
    notice "Setting up mail configuration..."
    php artisan p:environment:mail
}

# Create admin user
create_admin() {
    cd "$INSTALL_DIR"
    
    notice "Creating admin user..."
    php artisan p:user:make
}

# Setup cron and queue worker
setup_workers() {
    notice "Setting up cron job..."
    (crontab -l 2>/dev/null; echo "* * * * * php ${INSTALL_DIR}/artisan schedule:run >> /dev/null 2>&1") | crontab -
    
    notice "Creating queue worker service..."
    cat > /etc/systemd/system/pteroq.service <<EOF
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php ${INSTALL_DIR}/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable --now redis-server
    systemctl enable --now pteroq.service
}

# Set correct permissions
set_permissions() {
    notice "Setting correct permissions..."
    chown -R www-data:www-data "$INSTALL_DIR"/*
}

# Main installation function
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox Pterodactyl Installation"
    echo "============================================================================"
    
    # Initialize progress tracking
    echo "0" > "$progress_file"
    
    download_pterodactyl
    echo "1" > "$progress_file"
    
    configure_environment
    echo "2" > "$progress_file"
    
    setup_database
    echo "3" > "$progress_file"
    
    create_admin
    echo "4" > "$progress_file"
    
    setup_workers
    echo "5" > "$progress_file"
    
    set_permissions
    echo "6" > "$progress_file"
    
	configure_mail
    echo "7" > "$progress_file"
	
    # Cleanup
    rm -f "$progress_file"
    
    success "Pterodactyl Panel installation completed successfully!"
    notice "You can now access your panel through your configured domain."
}

# Execute main installation
main "$@"