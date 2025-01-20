#!/bin/bash
# /script/boot/WPA-Boot-Install.sh

# Source the main configuration
CONFIG_FILE="/root/WPA.conf"
BOOT_DIR="/root/WPA-ToolBox/boot"
MENU_SCRIPT="/root/WPA-ToolBox/scripts/WPA-Menu.sh"

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
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Get OS from config file
get_os_type() {
    if [ -f "$CONFIG_FILE" ]; then
        os_line=$(grep "^OS=" "$CONFIG_FILE")
        if [ -n "$os_line" ]; then
            # Extract OS name and capitalize first letter
            os_type=$(echo "$os_line" | cut -d'=' -f2 | cut -d'-' -f1)
            os_type="$(tr '[:lower:]' '[:upper:]' <<< ${os_type:0:1})${os_type:1}"
            echo "$os_type"
        else
            error "OS not found in config file"
            exit 1
        fi
    else
        error "Config file not found"
        exit 1
    fi
}

# Install boot requirements
install_boot_requirements() {
    local os_type=$(get_os_type)
    local os_script_url="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/refs/heads/v3/boot/${os_type}.sh"
    local target_script="${BOOT_DIR}/${os_type}.sh"
    
    notice "Downloading boot script for $os_type..."
    
    # Create boot directory if it doesn't exist
    mkdir -p "$BOOT_DIR"
    
    # Download the OS-specific script with retry
    local max_attempts=3
    local attempt=1
    local success=false
    
    while [ $attempt -le $max_attempts ]; do
        notice "Download attempt $attempt of $max_attempts..."
        
        if curl -s -o "$target_script" "$os_script_url"; then
            if [ -s "$target_script" ] && ! grep -q "<!DOCTYPE html>" "$target_script"; then
                success=true
                break
            fi
        fi
        
        warning "Attempt $attempt failed. Retrying in 5 seconds..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    if [ "$success" = false ]; then
        error "Failed to download boot script after $max_attempts attempts"
        return 1
    fi
    
    chmod +x "$target_script"
    notice "Running installation script for $os_type..."
    
    # Source and execute the script
    source "$target_script"
    
    # Check if the script executed successfully
    if [ $? -eq 0 ]; then
        success "Boot installation completed successfully"
        # Update booted status in config
        sed -i 's/^Booted=.*/Booted=1/' "$CONFIG_FILE"
        
        # Transition to menu if available
        if [ -f "$MENU_SCRIPT" ]; then
            notice "Launching menu..."
            sleep 2
            exec "$MENU_SCRIPT"
        else
            error "Menu script not found at $MENU_SCRIPT"
            exit 1
        fi
    else
        error "Boot installation failed"
        exit 1
    fi
}

# Main execution
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox | Boot Installation Script"
    echo "============================================================================"
    
    install_boot_requirements
}

# Execute main function
main "$@"