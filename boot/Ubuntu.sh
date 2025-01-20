#!/bin/bash
# Ubuntu.sh - Ubuntu-specific boot installation

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
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg certbot
}

add_repositories() {
    notice "Adding required repositories..."
    
    # PHP Repository
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    
    # MariaDB Repository (skip for 22.04)
    if [ "$(lsb_release -rs)" != "22.04" ]; then
        notice "Adding MariaDB repository..."
        curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
    fi
    
    # Universe repository for 18.04
    if [ "$(lsb_release -rs)" = "18.04" ]; then
        notice "Adding universe repository for 18.04..."
        apt-add-repository universe
    fi
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
ubuntu_install() {
    notice "Starting Ubuntu installation..."
    
    # Store current progress in temporary file
    progress_file="/tmp/ubuntu_install_progress"
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
    
    success "Ubuntu installation completed successfully"
    return 0
}

# Execute installation
ubuntu_install