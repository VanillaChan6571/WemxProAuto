#!/bin/bash
# WPA-CreateSSL.sh - SSL Certificate Creation and Management Script

# Set up error handling
set -e

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

# Configuration
SSL_INFO_DIR="/root/WPA-ToolBox/ssl"
CERT_INFO_FILE="${SSL_INFO_DIR}/certbot.txt"

# Function to handle errors
handle_error() {
    error "An error occurred during SSL setup at line $1"
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Check if certbot is installed
check_certbot() {
    if ! command -v certbot &> /dev/null; then
        notice "Installing certbot..."
        apt-get update
        apt-get install -y certbot
    fi
}

# Create required directories
setup_directories() {
    if [ ! -d "$SSL_INFO_DIR" ]; then
        mkdir -p "$SSL_INFO_DIR"
    fi
}

# Function to check and kill processes using ports 80/443
check_and_kill_ports() {
    notice "Checking for processes using ports 80 and 443..."
    
    # Stop nginx first
    notice "Stopping nginx service..."
    systemctl stop nginx 2>/dev/null || true
    
    # Function to kill processes on a specific port
    kill_port_process() {
        local port=$1
        local pid
        
        notice "Checking port $port..."
        
        # Try multiple times as some processes might respawn
        for i in {1..3}; do
            pid=$(lsof -ti :$port 2>/dev/null || true)
            if [ ! -z "$pid" ]; then
                warning "Found process (PID: $pid) using port $port. Attempting to kill... (Attempt $i)"
                kill -9 $pid 2>/dev/null || true
                sleep 2
            else
                notice "No process found using port $port"
                break
            fi
        done
        
        # Final check
        if lsof -ti :$port >/dev/null 2>&1; then
            warning "Port $port is still in use after kill attempts"
            return 0  # Continue anyway
        else
            notice "Port $port is free"
        fi
    }
    
    kill_port_process 80
    kill_port_process 443
    
    # Additional checks for other web servers
    notice "Checking for other web servers..."
    systemctl stop apache2 2>/dev/null || true
    
    # Final verification
    if ! lsof -ti :80 >/dev/null 2>&1 && ! lsof -ti :443 >/dev/null 2>&1; then
        success "Ports 80 and 443 are now available"
    else
        warning "Some ports may still be in use, but continuing anyway..."
    fi
}

# Function to save certificate information
save_cert_info() {
    local domain=$1
    local cert_path="/etc/letsencrypt/live/$domain"
    
    # Create or update certificate info file
    cat > "$CERT_INFO_FILE" << EOF
Domain: $domain
Certificate Path: $cert_path
Fullchain: $cert_path/fullchain.pem
Private Key: $cert_path/privkey.pem
Created: $(date)
EOF
    
    success "Certificate information saved to $CERT_INFO_FILE"
}

# Function to set up auto-renewal
setup_auto_renewal() {
    local current_crontab
    current_crontab=$(crontab -l 2>/dev/null || echo "")
    
    if ! echo "$current_crontab" | grep -q "certbot renew"; then
        notice "Setting up automatic certificate renewal..."
        (echo "$current_crontab"; echo "0 23 * * * certbot renew --quiet --deploy-hook \"systemctl restart nginx\"") | crontab -
        success "Auto-renewal cron job added"
    else
        notice "Auto-renewal cron job already exists"
    fi
}

# Main SSL creation function
create_ssl() {
    local domain=$1
    local method=$2
    local email_option=$3
    
    notice "Starting SSL certificate creation process for $domain..."
    check_and_kill_ports || warning "Port check completed with warnings"
    
    notice "Proceeding with certificate creation..."
    case $method in
        "auto")
            notice "Creating certificate using automatic method..."
            if [ "$email_option" = "none" ]; then
                certbot certonly --standalone -d "$domain" --register-unsafely-without-email --agree-tos
            else
                certbot certonly --standalone -d "$domain" -m "$email_option" --agree-tos
            fi
            ;;
        "manual")
            notice "Creating certificate using manual DNS challenge..."
            if [ "$email_option" = "none" ]; then
                certbot --manual --preferred-challenges dns -d "$domain" certonly --register-unsafely-without-email --agree-tos
            else
                certbot --manual --preferred-challenges dns -d "$domain" certonly -m "$email_option" --agree-tos
            fi
            ;;
        *)
            error "Invalid method specified"
            exit 1
            ;;
    esac
    
    save_cert_info "$domain"
    setup_auto_renewal
    
    # Restart services
    systemctl start nginx || warning "Failed to start nginx"
    
    # Check if wings service exists before attempting restart
    if systemctl list-unit-files | grep -q wings.service; then
        systemctl restart wings || warning "Failed to restart wings"
    else
        notice "Wings service not found - Wings has not been installed yet"
    fi
}

# Main execution
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox SSL Certificate Creation"
    echo "============================================================================"
    
    check_certbot
    setup_directories
    
    # Get domain from user
    read -p "Enter your domain (e.g., example.com): " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        error "Domain cannot be empty"
        exit 1
    fi
    
    # Get email preference
    echo
    echo "Email Options:"
    echo "1) Register without email (Not recommended)"
    echo "2) Register with email address (Recommended for renewal notifications)"
    read -p "Enter your choice (1-2): " EMAIL_CHOICE
    
    EMAIL_OPTION="none"
    case $EMAIL_CHOICE in
        2)
            read -p "Enter your email address: " EMAIL_OPTION
            if [ -z "$EMAIL_OPTION" ]; then
                warning "No email provided, proceeding without email registration"
                EMAIL_OPTION="none"
            fi
            ;;
        *)
            notice "Proceeding without email registration"
            ;;
    esac
    
    # Present method options
    echo
    echo "Select SSL creation method:"
    echo "1) Automatic (Recommended)"
    echo "2) Manual DNS Challenge"
    read -p "Enter your choice (1-2): " METHOD_CHOICE
    
    case $METHOD_CHOICE in
        1)
            create_ssl "$DOMAIN" "auto" "$EMAIL_OPTION"
            ;;
        2)
            create_ssl "$DOMAIN" "manual" "$EMAIL_OPTION"
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
    
    success "SSL certificate creation completed!"
    notice "Certificate information has been saved to $CERT_INFO_FILE"
}

# Execute main function
main "$@"