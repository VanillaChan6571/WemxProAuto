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

# Reusable download function with retries
download_with_retry() {
    local url=$1
    local output=$2
    local max_attempts=3
    local attempt=1
    local sleep_time=5
    
    while [ $attempt -le $max_attempts ]; do
        notice "Download attempt $attempt of $max_attempts..."
        
        if curl -sSf "$url" -o "$output"; then
            success "Download successful"
            return 0
        fi
        
        warning "Attempt $attempt failed."
        
        if [ $attempt -lt $max_attempts ]; then
            warning "Waiting $sleep_time seconds before next attempt..."
            sleep $sleep_time
            sleep_time=$((sleep_time * 2))
        fi
        
        attempt=$((attempt + 1))
    done
    
    error "Download failed after $max_attempts attempts"
    return 1
}

install_base_packages() {
    notice "Installing base packages..."
    apt update
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg certbot
}

add_repositories() {
    notice "Adding required repositories..."
    
    # PHP Repository with retry
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    
    # MariaDB Repository (skip for 22.04) with retry
    if [ "$(lsb_release -rs)" != "22.04" ]; then
        notice "Adding MariaDB repository..."
        local temp_file=$(mktemp)
        if download_with_retry "https://downloads.mariadb.com/MariaDB/mariadb_repo_setup" "$temp_file"; then
            bash "$temp_file"
            rm -f "$temp_file"
        else
            error "Failed to download MariaDB repository setup script"
            rm -f "$temp_file"
            return 1
        fi
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
    local temp_file=$(mktemp)
    local max_attempts=3
    local attempt=1
    local sleep_time=5
    
    while [ $attempt -le $max_attempts ]; do
        notice "Composer installation attempt $attempt of $max_attempts..."
        
        if download_with_retry "https://getcomposer.org/installer" "$temp_file"; then
            if php "$temp_file" -- --install-dir=/usr/local/bin --filename=composer; then
                rm -f "$temp_file"
                
                # Verify installation
                if command -v composer &> /dev/null; then
                    success "Composer installed successfully"
                    return 0
                fi
            fi
        fi
        
        warning "Attempt $attempt failed."
        
        if [ $attempt -lt $max_attempts ]; then
            warning "Waiting $sleep_time seconds before next attempt..."
            sleep $sleep_time
            sleep_time=$((sleep_time * 2))
        fi
        
        attempt=$((attempt + 1))
    done
    
    rm -f "$temp_file"
    error "Composer installation failed after $max_attempts attempts"
    return 1
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