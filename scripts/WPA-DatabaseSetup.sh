#!/bin/bash

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

# Function to generate random password
generate_password() {
    openssl rand -base64 16 | tr -d '/+=' | cut -c1-16
}

# Function to create directories if they don't exist
setup_directories() {
    if [ ! -d "/root/WPA-ToolBox/database" ]; then
        mkdir -p /root/WPA-ToolBox/database
        success "Created directory structure"
    fi
}

# Function to create database users
create_database_users() {
    local access_host="$1"
    local install_type="$2"
    local admin_user="$3"
    local admin_pass="$4"
    local wemx_pass=""
    local ptero_pass=""

    # Create super admin user
    mariadb -e "CREATE USER '$admin_user'@'%' IDENTIFIED BY '$admin_pass';"
    mariadb -e "GRANT ALL PRIVILEGES ON *.* TO '$admin_user'@'%' WITH GRANT OPTION;"

    # Create WemX user if needed
    if [[ "$install_type" == "wemx" || "$install_type" == "both" ]]; then
        wemx_pass=$(generate_password)
        mariadb -e "CREATE USER 'wemx'@'$access_host' IDENTIFIED BY '$wemx_pass';"
        mariadb -e "CREATE DATABASE IF NOT EXISTS wemx;"
        mariadb -e "GRANT ALL PRIVILEGES ON wemx.* TO 'wemx'@'$access_host' WITH GRANT OPTION;"
    fi

    # Create Pterodactyl user if needed
    if [[ "$install_type" == "ptero" || "$install_type" == "both" ]]; then
        ptero_pass=$(generate_password)
        mariadb -e "CREATE USER 'pterodactyl'@'$access_host' IDENTIFIED BY '$ptero_pass';"
        mariadb -e "CREATE DATABASE IF NOT EXISTS panel;"
        mariadb -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'$access_host' WITH GRANT OPTION;"
    fi

    mariadb -e "FLUSH PRIVILEGES;"

    # Save credentials to file
    {
        echo "Database Credentials - Generated on $(date)"
        echo "----------------------------------------"
        echo "Super Admin User: $admin_user"
        echo "Super Admin Password: $admin_pass"
        if [ -n "$wemx_pass" ]; then
            echo "WemX User: wemx"
            echo "WemX Password: $wemx_pass"
            echo "WemX Database: wemx"
        fi
        if [ -n "$ptero_pass" ]; then
            echo "Pterodactyl User: pterodactyl"
            echo "Pterodactyl Password: $ptero_pass"
            echo "Pterodactyl Database: panel"
        fi
        echo "Access Host: $access_host"
        echo "----------------------------------------"
    } > /root/WPA-ToolBox/database/CatSecrets.txt

    success "Database users created successfully"
    notice "Credentials saved to /root/WPA-ToolBox/database/CatSecrets.txt"
}

# Main execution
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox Database Setup"
    echo "============================================================================"

    setup_directories
    
    # Add this line to call handle_existing_secrets
    if ! handle_existing_secrets; then
        exit 0
    fi
    
    # First get access type
    access_host=""
    while true; do
        clear
        echo "============================================================================"
        echo "Database Access Type Selection"
        echo "============================================================================"
        echo
        echo "Where will you need to access your database from?"
        echo
        echo "1) External Access (%) - Choose this if:"
        echo "   - You need to connect from other servers"
        echo "   - You're using a remote database host"
        echo "   - You're using cPanel or external connections"
        echo "   - Less secure, but required for remote access"
        echo
        echo "2) Local Access Only (127.0.0.1) - Choose this if:"
        echo "   - Everything is on the same server"
        echo "   - You don't need remote database access"
        echo "   - More secure, recommended for single-server setups"
        echo
        read -r -p "Enter your choice (1-2): " access_choice
        case $access_choice in
            1)
                access_host="%"
                notice "Selected: External Access (%)"
                sleep 2
                break
                ;;
            2)
                access_host="127.0.0.1"
                notice "Selected: Local Access Only"
                sleep 2
                break
                ;;
            *)
                warning "Invalid choice. Please enter 1 or 2."
                sleep 2
                ;;
        esac
    done

    # Then get installation type
    install_type=""
    while true; do
        clear
        echo "============================================================================"
        echo "Database Installation Type Selection"
        echo "============================================================================"
        echo
        echo "Please select which software you need database users for:"
        echo
        echo "1) WemX only"
        echo "2) Pterodactyl only"
        echo "3) Both WemX and Pterodactyl"
        echo
        read -r -p "Enter your choice (1-3): " install_choice
        case $install_choice in
            1) 
                install_type="wemx"
                notice "Selected: WemX only"
                sleep 2
                break
                ;;
            2)
                install_type="ptero"
                notice "Selected: Pterodactyl only"
                sleep 2
                break
                ;;
            3)
                install_type="both"
                notice "Selected: Both WemX and Pterodactyl"
                sleep 2
                break
                ;;
            *)
                warning "Invalid choice. Please enter 1, 2, or 3."
                sleep 2
                ;;
        esac
    done

    # Finally get the admin username
    admin_user=""
    while true; do
        clear
        echo "============================================================================"
        echo "Database Super Admin Account Setup"
        echo "============================================================================"
        echo
        echo "Please enter a username for your database super admin account."
        echo "This account will have full privileges to manage all databases."
        echo "Example: admin_user, dbadmin, etc."
        echo
        read -r -p "Enter desired username for super admin account: " admin_user
        
        # Validate username is not empty
        if [ -z "$admin_user" ]; then
            warning "Username cannot be empty"
            sleep 2
            continue
        fi
        
        # Show what was entered and confirm
        echo
        notice "Username entered: $admin_user"
        echo
        read -r -p "Is this username correct? (y/n): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            admin_pass=$(generate_password)
            break
        fi
    done

    # Show final confirmation
    clear
    echo "============================================================================"
    echo "Please confirm your selections:"
    echo "============================================================================"
    echo
    echo "Access Type: $access_host"
	notice "The Admin User that You Created will be Remote Access"
    echo "Installation Type: $install_type"
    echo "Admin Username: $admin_user"
    echo
    echo "Note: Passwords will be automatically generated and saved to:"
    echo "/root/WPA-ToolBox/database/CatSecrets.txt"
    echo
    read -r -p "Proceed with these settings? (y/n): " final_confirm
    if [[ ! $final_confirm =~ ^[Yy]$ ]]; then
        notice "Setup cancelled. Starting over..."
        sleep 2
        main
        return
    fi

    # Create the database users
    notice "Creating database users..."
    create_database_users "$access_host" "$install_type" "$admin_user" "$admin_pass"
    
    success "Database setup completed successfully!"
}

# Run main function
main
