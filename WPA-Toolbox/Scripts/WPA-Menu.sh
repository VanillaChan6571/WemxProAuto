#!/bin/bash
# WPA-Menu.sh - Main menu system for WPA-ToolBox

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

# Get current version from WPA.conf
get_version() {
    if [ -f "/root/WPA.conf" ]; then
        grep "^version=" "/root/WPA.conf" | cut -d'=' -f2
    else
        echo "Unknown"
    fi
}

# Function to check database credentials
check_database_credentials() {
    local secrets_file="/root/WPA-ToolBox/database/CatSecrets.txt"
    local required_type="$1"  # wemx, pterodactyl, or both
    
    if [ ! -f "$secrets_file" ]; then
        return 1
    fi
    
    # Check for WemX credentials if needed
    if [[ "$required_type" == "wemx" || "$required_type" == "both" ]]; then
        if ! grep -q "WemX User:" "$secrets_file" || ! grep -q "WemX Password:" "$secrets_file"; then
            return 1
        fi
    fi
    
    # Check for Pterodactyl credentials if needed
    if [[ "$required_type" == "pterodactyl" || "$required_type" == "both" ]]; then
        if ! grep -q "Pterodactyl User:" "$secrets_file" || ! grep -q "Pterodactyl Password:" "$secrets_file"; then
            return 1
        fi
    fi
    
    return 0
}

# Function to check SSL certificates
check_ssl_certificates() {
    local domain_type="$1"  # wemx, pterodactyl, or both
    local ssl_dir="/root/WPA-ToolBox/ssl"
    
    if [ ! -d "$ssl_dir" ]; then
        return 1
    fi
    
    # Check for any SSL certificates
    if ! ls "$ssl_dir"/ssl-*.txt >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Function to confirm component installation
confirm_component() {
    local component="$1"
    local check_result="$2"
    local skip_message="$3"
    local install_message="$4"
    
    if [ "$check_result" -eq 0 ]; then
        notice "$skip_message"
        read -p "Would you like to skip this step? (Y/n): " skip_choice
        if [[ $skip_choice =~ ^[Yy]$ || $skip_choice == "" ]]; then
            return 1
        fi
    else
        notice "$install_message"
    fi
    return 0
}

# Function to run installation chain
run_installation_chain() {
    local components=("$@")
    local current_step=1
    local total_steps=${#components[@]}
    local components_to_install=()
    
    # First, check existing components and ask user preferences
    for component in "${components[@]}"; do
        case $component in
            "database")
                if check_database_credentials "both"; then
                    if confirm_component "database" 0 \
                        "Existing database credentials found." \
                        "No database credentials found."; then
                        components_to_install+=("database")
                    fi
                else
                    components_to_install+=("database")
                fi
                ;;
            "ssl")
                if check_ssl_certificates "both"; then
                    if confirm_component "ssl" 0 \
                        "Existing SSL certificates found." \
                        "No SSL certificates found."; then
                        components_to_install+=("ssl")
                    fi
                else
                    components_to_install+=("ssl")
                fi
                ;;
            *)
                components_to_install+=("$component")
                ;;
        esac
    done
    
    # Update total steps count based on user choices
    total_steps=${#components_to_install[@]}
    
    # Now run the actual installation
    for component in "${components_to_install[@]}"; do
        clear
        echo "============================================================================"
        echo "Step $current_step of $total_steps: Installing $component"
        echo "============================================================================"
        
        case $component in
            "database")
                source "/root/WPA-ToolBox/scripts/WPA-DatabaseSetup.sh"
                if ! main; then
                    error "Database setup failed"
                    return 1
                fi
                ;;
            "ssl")
                source "/root/WPA-ToolBox/scripts/WPA-CreateSSL.sh"
                if ! main; then
                    error "SSL setup failed"
                    return 1
                fi
                ;;
            "wemx")
                source "/root/WPA-ToolBox/scripts/WPA-WemxInstall.sh"
                if ! main; then
                    error "WemX installation failed"
                    return 1
                fi
                ;;
            "pterodactyl")
                source "/root/WPA-ToolBox/scripts/WPA-PteroInstall.sh"
                if ! main; then
                    error "Pterodactyl installation failed"
                    return 1
                fi
                ;;
            "wings")
                source "/root/WPA-ToolBox/scripts/WPA-PteroWingsInstall.sh"
                if ! main; then
                    error "Wings installation failed"
                    return 1
                fi
                ;;
            "nginx")
                source "/root/WPA-ToolBox/scripts/WPA-Nginx.sh"
                if ! main; then
                    error "Nginx configuration failed"
                    return 1
                fi
                ;;
        esac
        
        ((current_step++))
    done
    
    success "Installation chain completed successfully"
    return 0
}

# Show welcome message
show_welcome() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox Script $(get_version)"
    echo
    echo "Copyright (C) 2021 - $(date +%Y), NekoHosting LLC"
    echo "https://github.com/VanillaChan6571/WemxProAuto"
    echo
    echo "============================================================================"
    
    sleep 3
    show_menu
}

# Main menu
show_menu() {
    while true; do
        clear
        echo "============================================================================"
        echo "WemxPRO | WPA ToolBox Script $(get_version) - Main Menu"
        echo "============================================================================"
        echo
        echo "1) Full Installation (Database → SSL → WemX → Pterodactyl → Wings → Nginx)"
        echo "2) WemX Only Installation (Database → SSL → WemX → Nginx)"
        echo "3) Game Panel Only Installation (Database → SSL → Pterodactyl → Wings → Nginx)"
        echo "4) Custom Installation (Select Components)"
        echo "5) Update WemX"
        echo "6) Manage SSL Certificates"
        echo "7) Create Users"
        echo "8) Exit"
        echo
        read -p "Select an option (1-8): " choice
        
        case $choice in
            1)
                run_installation_chain "database" "ssl" "wemx" "pterodactyl" "wings" "nginx"
                ;;
            2)
                run_installation_chain "database" "ssl" "wemx" "nginx"
                ;;
            3)
                run_installation_chain "database" "ssl" "pterodactyl" "wings" "nginx"
                ;;
            4)
                show_custom_installation
                ;;
            5)
                update_wemx
                ;;
            6)
                manage_ssl
                ;;
            7)
                show_user_menu
                ;;
            8)
                echo "Exiting..."
                exit 0
                ;;
            *)
                error "Invalid option"
                sleep 2
                ;;
        esac
    done
}

# Custom installation menu
show_custom_installation() {
    clear
    echo "============================================================================"
    echo "Custom Installation - Select Components"
    echo "============================================================================"
    echo
    echo "Available components:"
    echo "1) Database Setup"
    echo "2) SSL Certificate"
    echo "3) WemX"
    echo "4) Pterodactyl Panel"
    echo "5) Pterodactyl Wings"
    echo "6) Nginx Configuration"
    echo "7) Start Installation"
    echo "8) Back to Main Menu"
    echo
    
    declare -a selected_components=()
    
    while true; do
        read -p "Select component to add (1-8): " component
        case $component in
            1) selected_components+=("database");;
            2) selected_components+=("ssl");;
            3) selected_components+=("wemx");;
            4) selected_components+=("pterodactyl");;
            5) selected_components+=("wings");;
            6) selected_components+=("nginx");;
            7) 
                if [ ${#selected_components[@]} -eq 0 ]; then
                    warning "No components selected"
                else
                    run_installation_chain "${selected_components[@]}"
                fi
                break
                ;;
            8) return;;
            *) error "Invalid option";;
        esac
    done
}

# Update WemX
update_wemx() {
    source "/root/WPA-ToolBox/scripts/WPA-WemxInstall.sh"
    update_main
}

# Manage SSL certificates
manage_ssl() {
    source "/root/WPA-ToolBox/scripts/WPA-CreateSSL.sh"
    main
}

# Show user management menu
show_user_menu() {
    clear
    echo "============================================================================"
    echo "User Management"
    echo "============================================================================"
    echo
    echo "1) Create WemX User"
    echo "2) Create Pterodactyl User"
    echo "3) Back to Main Menu"
    
    read -p "Select an option (1-3): " choice
    case $choice in
        1)
            cd /var/www/wemx
            php artisan user:create
            ;;
        2)
            cd /var/www/pterodactyl
            php artisan p:user:make
            ;;
        3)
            return
            ;;
        *)
            error "Invalid option"
            sleep 2
            ;;
    esac
}

# Start the menu system
show_welcome