#!/bin/bash
# WPA-Nginx.sh - Nginx Configuration Script

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
    error "An error occurred during nginx configuration at line $1"
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Function to get domain from SSL info
get_domain_info() {
    local service=$1
    local safe_domain=$(echo "$2" | tr '.' '-')
    local ssl_info_file="/root/WPA-ToolBox/ssl/ssl-${safe_domain}.txt"
    
    if [ ! -f "$ssl_info_file" ]; then
        error "SSL information not found for $2. Please run SSL setup first."
        exit 1
    fi
    
    success "Found SSL configuration for $2"
}

# Function to configure Pterodactyl nginx
configure_pterodactyl() {
    local domain=$1
    notice "Configuring Nginx for Pterodactyl Panel at $domain..."
    
    cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;
    
    root /var/www/pterodactyl/public;
    index index.php;
    
    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;
    
    client_max_body_size 100m;
    client_body_timeout 120s;
    
    sendfile off;
    
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;
    
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    success "Pterodactyl Nginx configuration created"
}

# Function to configure WemX nginx
configure_wemx() {
    local domain=$1
    notice "Configuring Nginx for WemX at $domain..."
    
    cat > /etc/nginx/sites-available/wemx.conf <<EOF
server {
    listen 80;
    server_name $domain;
    server_tokens off;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;
    
    root /var/www/wemx/public;
    index index.php;
    
    access_log /var/log/nginx/wemx.app-access.log;
    error_log  /var/log/nginx/wemx.app-error.log error;
    
    client_max_body_size 100m;
    client_body_timeout 120s;
    
    sendfile off;
    
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;
    
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag "index, follow";
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/wemx.conf /etc/nginx/sites-enabled/wemx.conf
    success "WemX Nginx configuration created"
}

# Main function
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox Nginx Configuration"
    echo "============================================================================"
    
    # Remove default nginx config
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        rm -f /etc/nginx/sites-enabled/default
        notice "Removed default Nginx configuration"
    fi
    
    # Prompt for configuration type
    echo "Please select which service(s) to configure:"
    echo "1) WemX only"
    echo "2) Pterodactyl only"
    echo "3) Both WemX and Pterodactyl"
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            read -p "Enter domain for WemX: " wemx_domain
            get_domain_info "wemx" "$wemx_domain"
            configure_wemx "$wemx_domain"
            ;;
        2)
            read -p "Enter domain for Pterodactyl: " ptero_domain
            get_domain_info "pterodactyl" "$ptero_domain"
            configure_pterodactyl "$ptero_domain"
            ;;
        3)
            read -p "Enter domain for WemX: " wemx_domain
            read -p "Enter domain for Pterodactyl: " ptero_domain
            get_domain_info "wemx" "$wemx_domain"
            get_domain_info "pterodactyl" "$ptero_domain"
            configure_wemx "$wemx_domain"
            configure_pterodactyl "$ptero_domain"
            ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Test nginx configuration
    notice "Testing Nginx configuration..."
    if nginx -t; then
        systemctl restart nginx
        success "Nginx configuration test passed and service restarted"
    else
        error "Nginx configuration test failed"
        exit 1
    fi
    
    success "Nginx configuration completed successfully!"
}

# Execute main function
main "$@"