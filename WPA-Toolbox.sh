#!/bin/bash

# Check if running as root unless override flag is used
if [[ $EUID -ne 0 ]] && [[ "$1" != "-ignore-root-only-cause-i-am-dumb" ]]; then
    echo "Oops! You did not run this as ROOT; Sudo does cannot override the locked files sometimes, ROOT modifies the files no matter if locked or not."
    echo -e "* ${COLOR_BLUE}NOTICE${COLOR_NC}: If you wish to continue without ROOT and its special powers (This will likely install will fail or incomplete the install) You can add the following flag: -ignore-root-only-cause-i-am-dumb"
    sleep 5s
    exit 1
fi

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

# Version and version check URL
CURRENT_VERSION_URL="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/refs/heads/v3/VersionCheck.txt"
LOCAL_VERSION=""
REMOTE_VERSION=""

# Required script files
REQUIRED_SCRIPTS=(
    "WPA-CreateSSL.sh"
    "WPA-DatabaseSetup.sh"
    "WPA-Menu.sh"
    "WPA-Nginx.sh"
    "WPA-PteroInstall.sh"
    "WPA-PteroWingsInstall.sh"
    "WPA-WemxInstall.sh"
)

# Base directories and paths
BASE_DIR="/root/WPA-ToolBox"
SCRIPTS_DIR="$BASE_DIR/scripts"
BOOT_DIR="$BASE_DIR/boot"
CONFIG_FILE="/root/WPA.conf"
BOOT_SCRIPT="$BOOT_DIR/WPA-Boot-Install.sh"

# GitHub base URLs
GITHUB_BASE="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/refs/heads/v3/scripts"
GITHUB_BOOT="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/refs/heads/v3/boot"

# Required script files
REQUIRED_SCRIPTS=(
    "WPA-CreateSSL.sh"
    "WPA-DatabaseSetup.sh"
    "WPA-Menu.sh"
    "WPA-Nginx.sh"
    "WPA-PteroInstall.sh"
    "WPA-PteroWingsInstall.sh"
    "WPA-WemxInstall.sh"
)

# Create required directories
create_directories() {
    notice "Creating required directories..."
    mkdir -p "$SCRIPTS_DIR" "$BOOT_DIR"
    if [ $? -eq 0 ]; then
        success "Directories created successfully"
    else
        error "Failed to create directories"
        exit 1
    fi
}

# Download a single file with retries
download_file() {
    local file=$1
    local directory=$2
    local base_url=$3
    local max_retries=3
    local retry_delay=2
    local attempt=1
    
    notice "Downloading $file..."
    local full_url="${base_url}/${file}"
    notice "URL: $full_url"
    
    while [ $attempt -le $max_retries ]; do
        # Try to download and capture both output and status
        local temp_file="${directory}/${file}.tmp"
        if curl -s -f -o "$temp_file" "$full_url"; then
            mv "$temp_file" "${directory}/${file}"
            chmod +x "${directory}/${file}"
            success "Downloaded and set permissions for $file"
            return 0
        else
            local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$full_url")
            warning "Attempt $attempt of $max_retries failed for $file (HTTP Status: $http_code)"
            
            if [ $attempt -lt $max_retries ]; then
                notice "Waiting ${retry_delay} seconds before retrying..."
                sleep $retry_delay
                # Increase delay for next attempt
                retry_delay=$((retry_delay * 2))
            fi
            rm -f "$temp_file"
            attempt=$((attempt + 1))
        fi
    done
    
    error "Failed to download $file after $max_retries attempts"
    error "URL: $full_url"
    return 1
}

# Check and download missing script files
check_script_files() {
    notice "Checking script files..."
    local missing_files=0
    local download_failed=0
    
    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if [ ! -f "$SCRIPTS_DIR/$script" ]; then
            warning "Missing script: $script"
            download_file "$script" "$SCRIPTS_DIR" "$GITHUB_BASE"
            if [ $? -ne 0 ]; then
                download_failed=1
                error "Failed to download: $script"
                missing_files=1
            fi
            # Add delay between downloads to avoid rate limiting
            sleep 1
        fi
    done
    
    if [ $download_failed -eq 1 ]; then
        error "Some files failed to download. Please check your internet connection and try again."
        return 1
    fi
    
    return $missing_files
}

# Check and download boot file
check_boot_file() {
    notice "Checking boot installation file..."
    if [ ! -f "$BOOT_DIR/WPA-Boot-Install.sh" ]; then
        warning "Missing boot installation script"
        download_file "WPA-Boot-Install.sh" "$BOOT_DIR" "$GITHUB_BOOT"
        return $?
    fi
    return 0
}

# Get local version from WPA.conf
get_local_version() {
    if [ -f "$CONFIG_FILE" ]; then
        LOCAL_VERSION=$(grep "^WPA=" "$CONFIG_FILE" | cut -d'=' -f2)
        if [ -z "$LOCAL_VERSION" ]; then
            warning "No version found in WPA.conf"
            return 1
        fi
        return 0
    else
        warning "WPA.conf not found"
        return 1
    fi
}

# Get remote version from GitHub
get_remote_version() {
    REMOTE_VERSION=$(curl -s "$CURRENT_VERSION_URL")
    if [ -z "$REMOTE_VERSION" ]; then
        error "Failed to fetch remote version"
        return 1
    fi
    return 0
}

# Compare versions and handle updates
check_for_updates() {
    get_local_version
    get_remote_version
    
    if [ -n "$LOCAL_VERSION" ] && [ -n "$REMOTE_VERSION" ]; then
        if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
            warning "Update available: $LOCAL_VERSION -> $REMOTE_VERSION"
            read -p "Would you like to update? (y/N): " choice
            case "$choice" in
                y|Y )
                    notice "Updating..."
                    # Re-download all script files
                    rm -rf "$SCRIPTS_DIR"/*
                    check_script_files
                    # Update version in WPA.conf
                    sed -i "s/^WPA=.*/WPA=$REMOTE_VERSION/" "$CONFIG_FILE"
                    success "Updated to version $REMOTE_VERSION"
                    ;;
                * )
                    notice "Continuing with current version"
                    ;;
            esac
        else
            success "You are running the latest version ($LOCAL_VERSION)"
        fi
    fi
}

# Check if system has been booted
check_boot_status() {
    if [ ! -f "$CONFIG_FILE" ]; then
        warning "WPA.conf not found. Creating new configuration..."
        cat > "$CONFIG_FILE" << EOF
WPA=3.0.0
Booted=0
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')-$(lsb_release -rs)
EOF
        return 1
    fi
    
    local booted=$(grep "^Booted=" "$CONFIG_FILE" | cut -d'=' -f2)
    if [ "$booted" = "1" ]; then
        notice "System has already been booted"
        check_for_updates
        if [ -f "$SCRIPTS_DIR/WPA-Menu.sh" ]; then
            success "Loading menu..."
            source "$SCRIPTS_DIR/WPA-Menu.sh"
            exit 0
        else
            error "Menu script not found!"
            exit 1
        fi
    else
        notice "System needs to be booted"
        return 1
    fi
}

# Handle safe mode
handle_safe_mode() {
    notice "Safe Mode activated"
    echo "This will perform a clean installation by removing all existing script files."
    read -p "Are you sure you want to continue? (y/N): " choice
    case "$choice" in
        y|Y )
            notice "Removing existing files..."
            rm -rf "$SCRIPTS_DIR"/* "$BOOT_DIR"/*
            success "Existing files removed"
            notice "Downloading fresh script files..."
            check_script_files
            check_boot_file
            success "Fresh files downloaded"
            notice "Safe Mode completed. Please run the script normally now."
            exit 0
            ;;
        * )
            notice "Safe Mode cancelled"
            exit 0
            ;;
    esac
}

# Main function
main() {
    # Check for safe mode flag
    if [ "$1" = "--safemode" ]; then
        handle_safe_mode
    fi
    clear
    echo "============================================================================"
    echo "WPA-ToolBox Installation Script"
    echo "============================================================================"
    
    # Check if already booted
    check_boot_status
    
    # Create directories if they don't exist
    create_directories
    
    # Check and download required files
    local files_ok=0
    check_script_files
    files_ok=$?
    
    check_boot_file
    boot_ok=$?
    
    if [ $files_ok -eq 0 ] && [ $boot_ok -eq 0 ]; then
        success "All required files are present"
        
        if [ -f "$BOOT_DIR/WPA-Boot-Install.sh" ]; then
            notice "Starting boot installation..."
            source "$BOOT_DIR/WPA-Boot-Install.sh"
            if [ $? -eq 0 ]; then
                success "Boot installation completed"
            else
                error "Boot installation failed"
                exit 1
            fi
        else
            error "Boot installation script not found after verification"
            exit 1
        fi
    else
        error "Failed to verify or download required files"
        exit 1
    fi
}

# Execute main function
main "$@"
