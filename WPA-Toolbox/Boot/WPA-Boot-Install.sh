#!/bin/bash
# /script/boot/WPA-Boot-Install.sh

# Source the main configuration
CONFIG_FILE="/root/WPA.conf"

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

# Get OS from config file
get_os_type() {
    if [ -f "$CONFIG_FILE" ]; then
        os_line=$(grep "^OS=" "$CONFIG_FILE")
        if [ -n "$os_line" ]; then
            echo "$os_line" | cut -d'=' -f2 | cut -d'-' -f1
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
    local os_script_url="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/refs/heads/main/WPA-Toolbox/Boot/${os_type}.sh"
    
    notice "Downloading boot script for $os_type..."
    
    # Create temporary directory
    temp_dir=$(mktemp -d)
    temp_script="${temp_dir}/${os_type}_boot.sh"
    
    # Download the OS-specific script
    if curl -s -o "$temp_script" "$os_script_url"; then
        chmod +x "$temp_script"
        
        notice "Running installation script for $os_type..."
        # Source and execute the script
        source "$temp_script"
        
        # Check if the script executed successfully
        if [ $? -eq 0 ]; then
            success "Boot installation completed successfully"
            # Update booted status in config
            sed -i 's/^Booted=.*/Booted=1/' "$CONFIG_FILE"
        else
            error "Boot installation failed"
            exit 1
        fi
    else
        error "Failed to download boot script for $os_type"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Main execution
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox | Boot Installation Script"
    echo "============================================================================"
    
    install_boot_requirements
}

main "$@"