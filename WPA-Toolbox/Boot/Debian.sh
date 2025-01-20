#!/bin/bash
# Debian.sh - Debian-specific boot installation

# Set up error handling
set -e

# Function to handle errors
handle_error() {
    error "An error occurred during installation at line $1"
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

install_base_packages() {
    notice "Installing base packages..."
    apt update
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg wget certbot
}

add_repositories() {
    notice "Adding required repositories..."
    
    # PHP Repository for Debian
    curl -sSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/php.gpg
    echo "deb [signed-by=/usr/share/keyrings/php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
    
    # MariaDB Repository
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
}

install_dependencies() {
    notice "Installing dependencies..."
    apt update
    apt -y install \
        php8.3 \
        php8.3-common \
        php8.3-cli \
        php8.3-gd \
        php8.3-mysql \
        php8.3-mbstring \
        php8.3-bcmath \
        php8.3-xml \
        php8.3-fpm \
        php8.3-curl \
        php8.3-zip \
        mariadb-server \
        nginx \
        tar \
        unzip \
        git \
		redis-server
}

install_composer() {
    notice "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
    # Verify composer installation
    if ! command -v composer &> /dev/null; then
        error "Composer installation failed"
        return 1
    fi
}

# Main installation function
debian_install() {
    notice "Starting Debian installation..."
    
    # Store current progress in temporary file
    progress_file="/tmp/debian_install_progress"
    echo "0" > "$progress_file"
    
    # Step 1: Base packages
    if [ "$(cat $progress_file)" -eq "0" ]; then
        install_base_packages
        echo "1" > "$progress_file"
    fi
    
    # Step 2: Repositories
    if [ "$(cat $progress_file)" -eq "1" ]; then
        add_repositories
        echo "2" > "$progress_file"
    fi
    
    # Step 3: Dependencies
    if [ "$(cat $progress_file)" -eq "2" ]; then
        install_dependencies
        echo "3" > "$progress_file"
    fi
    
    # Step 4: Composer
    if [ "$(cat $progress_file)" -eq "3" ]; then
        install_composer
        echo "4" > "$progress_file"
    fi
    
    # Clean up
    rm -f "$progress_file"
    
    success "Debian installation completed successfully"
    return 0
}

# Execute installation
debian_install