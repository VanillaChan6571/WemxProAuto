#!/bin/bash
# /root/WPA-Toolbox/scripts/WPA-Menu.sh

# Color definitions
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_ORANGE='\033[0;33m'
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
        grep "^WPA=" "/root/WPA.conf" | cut -d'=' -f2
    else
        echo "Unknown"
    fi
}

# Display changelog and welcome message
show_welcome() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox Script $(get_version) EXPERIMENTAL"
    echo
    echo "Copyright (C) 2021 - $(date +%Y), NekoHosting LLC"
    echo "https://github.com/VanillaChan6571/WemxProAuto"
    echo
    echo "============================================================================"
    echo "Patch Notes for 2.2.1"
    echo "+ Updated Repo for php since php8.1 is no longer supported. [php8.2]"
    echo "============================================================================"
    echo "Patch Notes for 2.2.0c"
    echo "+ Updated Repo for MariaDB since 11.1 is no longer supported. [11.2]"
    echo "============================================================================"
    echo "Patch Notes for 2.2.0"
    echo "+ Added TinyMC API Key Replacer"
    echo "This means you can just paste your key and automatically replace it!"
    echo " "
    notice "Showing the New Menu in 10 seconds... please wait..."
    sleep 10s
    show_menu
}

# Main menu function
show_menu() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox Script $(get_version) EXPERIMENTAL - Main Menu"
    echo "============================================================================"
    echo

    echo "Select the type of installation:"
    options=("Install" "UpdateWemx" "RenewCert" "UserCreate" "MakeMyDBPublic" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Install")
                source "/root/WPA-Toolbox/scripts/install.sh"
                show_install_menu
                ;;
            "UpdateWemx")
                echo "Updating Wemx Confirmed! | Preparing..."
                sleep 5s
                source "/root/WPA-Toolbox/scripts/wemx.sh"
                wemx_update
                ;;
            "RenewCert")
                echo "Proceeding with renewing certificates..."
                sudo certbot renew
                read -p "Press enter to continue..."
                show_menu
                ;;
            "UserCreate")
                source "/root/WPA-Toolbox/scripts/user.sh"
                show_user_create_menu
                ;;
            "MakeMyDBPublic")
                source "/root/WPA-Toolbox/scripts/database.sh"
                make_db_public
                ;;
            "Quit")
                echo "Exiting..."
                exit 0
                ;;
            *) 
                if [[ $REPLY == "DEV_DEBUG_ME" ]]; then
                    show_hidden_menu
                else
                    echo "Invalid option. Please try again."
                fi
                ;;
        esac
    done
}

# Hidden debug menu
show_hidden_menu() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox $(get_version) - DEBUG MENU "
    warning "If you do not know what your doing, then this isn't the correct area for you."
    echo "============================================================================"
    echo 
    echo "DEBUG_JUMP_TO_CERTAIN_AREAS:"
    options=(
        "Full Install" "Admin User Create DB" "DB Node Install" "Full Install DB" 
        "Full Install Continue" "Full Certbot SSL" "Full Web Server" "Full Wings" 
        "Wings Finalize" "Wemx Install" "Adminuser Create DB Wemx" "Wemx Install DB" 
        "Ask MySQL Secure" "MySQL Secure" "Wemx Install Continue" "Finish Installing" 
        "Fresh Boot" "Skip Fresh Boot" "Reboot From Start" "Quit" "Back" "SOW"
    )
    
    select opt in "${options[@]}"; do
        case $opt in
            "Full Install")
                read -p "Are you sure you want to proceed with Full Install? (y/n): " confirm
                if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
                    echo "Proceeding..."
                    source "/root/WPA-Toolbox/scripts/install.sh"
                    full_install
                else
                    echo "Canceled."
                fi
                break
                ;;
            # Add all other debug menu options here...
            "Back")
                show_menu
                ;;
            "Quit"|"Exit")
                echo "Exiting..."
                exit 0
                ;;
            *) 
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Start the menu system
show_welcome