#!/bin/bash

# Function for manual distribution selection
manual_distro_select() {
    clear
    echo "============================================================================"
    echo "Manual Distribution Selection"
    echo "============================================================================"
    echo
    notice "Auto-detection failed or returned unknown distribution."
    echo "Please select the distribution that most closely matches your system:"
    echo
    
    options=(
        "Ubuntu 22.04 (or compatible)"
        "Ubuntu 20.04 (or compatible)"
        "Ubuntu 18.04 (or compatible)"
        "Debian 12 (or compatible)"
        "Debian 11 (or compatible)"
        "Debian 10 (or compatible)"
        "CentOS/RHEL 8 (or compatible)"
        "CentOS/RHEL 9 (or compatible)"
        "Exit Installation"
    )

    select opt in "${options[@]}"; do
        case $opt in
            "Ubuntu 22.04 (or compatible)")
                DISTRO_NAME="ubuntu"
                DISTRO_VERSION="22.04"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "Ubuntu 20.04 (or compatible)")
                DISTRO_NAME="ubuntu"
                DISTRO_VERSION="20.04"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "Ubuntu 18.04 (or compatible)")
                DISTRO_NAME="ubuntu"
                DISTRO_VERSION="18.04"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "Debian 12 (or compatible)")
                DISTRO_NAME="debian"
                DISTRO_VERSION="12"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "Debian 11 (or compatible)")
                DISTRO_NAME="debian"
                DISTRO_VERSION="11"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "Debian 10 (or compatible)")
                DISTRO_NAME="debian"
                DISTRO_VERSION="10"
                PACKAGE_MANAGER="apt"
                break
                ;;
            "CentOS/RHEL 8 (or compatible)")
                DISTRO_NAME="centos"
                DISTRO_VERSION="8"
                PACKAGE_MANAGER="dnf"
                break
                ;;
            "CentOS/RHEL 9 (or compatible)")
                DISTRO_NAME="centos"
                DISTRO_VERSION="9"
                PACKAGE_MANAGER="dnf"
                break
                ;;
            "Exit Installation")
                echo "Installation cancelled by user."
                exit 1
                ;;
            *) 
                echo "Invalid option. Please try again."
                ;;
        esac
    done

    # Confirm selection
    echo
    echo "You have selected: $DISTRO_NAME $DISTRO_VERSION"
    warning "The installation will proceed treating your system as $DISTRO_NAME $DISTRO_VERSION"
    echo
    read -p "Is this correct? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        manual_distro_select
    fi
}

# Modified detect_linux_distro function
detect_linux_distro() {
    # Try to detect automatically first
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_NAME=$ID
        DISTRO_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_NAME=$(echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]')
        DISTRO_VERSION=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        DISTRO_NAME="debian"
        DISTRO_VERSION=$(cat /etc/debian_version)
    elif [ -f /etc/centos-release ]; then
        DISTRO_NAME="centos"
        DISTRO_VERSION=$(cat /etc/centos-release | cut -d" " -f4)
    elif [ -f /etc/redhat-release ]; then
        DISTRO_NAME="redhat"
        DISTRO_VERSION=$(cat /etc/redhat-release | cut -d" " -f4)
    else
        DISTRO_NAME="unknown"
        DISTRO_VERSION="unknown"
    fi

    # If auto-detection failed or returned unknown
    if [ "$DISTRO_NAME" = "unknown" ] || [ "$DISTRO_VERSION" = "unknown" ]; then
        notice "Unable to automatically detect your distribution."
        echo "Your system appears to be a custom or modified distribution."
        echo
        read -p "Would you like to manually select your distribution type? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            error "Cannot proceed without knowing the distribution type."
            exit 1
        fi
        manual_distro_select
    else
        # Show detected info and offer manual selection anyway
        notice "Detected distribution: $DISTRO_NAME $DISTRO_VERSION"
        echo
        read -p "Would you like to manually override this detection? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            manual_distro_select
        fi
    fi

    export DISTRO_NAME DISTRO_VERSION PACKAGE_MANAGER
}

# Modified check_distro_support function
check_distro_support() {
    case "$DISTRO_NAME" in
        "ubuntu")
            case "$DISTRO_VERSION" in
                18.04|20.04|22.04|22.10|23.04|23.10)
                    success "Ubuntu $DISTRO_VERSION is fully supported"
                    ;;
                *)
                    warning "Ubuntu $DISTRO_VERSION is not officially supported"
                    warning "The installer will attempt to use Ubuntu 22.04 compatibility mode"
                    notice "Some features may not work as expected"
                    ;;
            esac
            ;;
        "debian")
            if [[ $(echo "$DISTRO_VERSION >= 10" | bc) -eq 1 ]]; then
                success "Debian $DISTRO_VERSION is supported"
            else
                warning "Debian $DISTRO_VERSION is not officially supported"
                warning "The installer will attempt to use Debian 11 compatibility mode"
                notice "Some features may not work as expected"
            fi
            ;;
        "centos"|"rhel"|"rocky"|"almalinux")
            if [[ $(echo "$DISTRO_VERSION >= 8" | bc) -eq 1 ]]; then
                success "$DISTRO_NAME $DISTRO_VERSION is supported"
            else
                warning "$DISTRO_NAME $DISTRO_VERSION is not officially supported"
                warning "The installer will attempt to use CentOS 8 compatibility mode"
                notice "Some features may not work as expected"
            fi
            ;;
        *)
            error "Unknown distribution type after manual selection. This is a bug!"
            exit 1
            ;;
    esac

    echo
    read -p "Do you want to continue with the installation? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi
    return 0
}

# Usage in main function remains the same
main() {
    # ... rest of your main function ...
    
    detect_linux_distro
    check_distro_support
    
    # ... continue with your main function ...
}