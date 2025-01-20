#!/bin/bash
# WPA-PteroWingsInstall.sh - Automated Wings Installation Script

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

# Function to handle errors
handle_error() {
    error "An error occurred during installation at line $1"
    if [ -f "$progress_file" ]; then
        error "Installation failed at step $(cat $progress_file)"
    fi
    exit 1
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Progress tracking
progress_file="/tmp/wings_install_progress"

# Check system compatibility
check_compatibility() {
    notice "Checking system compatibility..."
    
    # Check virtualization
    VIRTUALIZATION=$(systemd-detect-virt)
    MANUFACTURER=$(dmidecode -s system-manufacturer 2>/dev/null || echo "unknown")
    
    case $VIRTUALIZATION in
        "openvz"|"lxc")
            error "OpenVZ or LXC virtualization detected. Wings cannot run in this environment."
            exit 1
            ;;
        "none")
            success "Running on dedicated hardware"
            ;;
        *)
            if [[ $MANUFACTURER == *"Virtuozzo"* ]]; then
                error "Virtuozzo virtualization detected. Wings cannot run in this environment."
                exit 1
            else
                warning "Running in a virtualized environment ($VIRTUALIZATION)"
                warning "Some features may not work as expected"
            fi
            ;;
    esac
}

# Install Docker
install_docker() {
    notice "Installing Docker..."
    
    # Install required packages
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Verify Docker installation
    if ! docker info &>/dev/null; then
        error "Docker installation failed"
        exit 1
    fi
    
    success "Docker installed successfully"
}

# Configure SWAP limits
configure_swap() {
    notice "Configuring swap limits..."
    
    if docker info 2>&1 | grep -q "WARNING: No swap limit support"; then
        notice "Enabling swap limit support..."
        
        # Backup GRUB configuration
        cp /etc/default/grub /etc/default/grub.backup
        
        # Add or update swapaccount parameter
        if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub; then
            sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"/' /etc/default/grub
        else
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"' >> /etc/default/grub
        fi
        
        # Update GRUB
        update-grub
        
        notice "Swap limits configured. A reboot will be required."
    else
        notice "Swap limit support already enabled"
    fi
}

# Install Wings
install_wings() {
    notice "Installing Pterodactyl Wings..."
    
    mkdir -p /etc/pterodactyl
    cd /etc/pterodactyl
    
    # Determine system architecture
    ARCH=$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")
    
    # Download Wings
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH"
    chmod u+x /usr/local/bin/wings
    
    # Create Wings configuration file
    if [ ! -f "/etc/pterodactyl/config.yml" ]; then
        touch /etc/pterodactyl/config.yml
    fi
}

# Setup data directory
setup_data_directory() {
    notice "Setting up Wings data directory..."
    
    # Check if running on OVH/SYS
    if df -h | grep -q '/home'; then
        warning "OVH/SYS server detected. Consider using /home/daemon-data for server data."
        
        options=(
            "/home/daemon-data/var/lib/pterodactyl"
            "/var/lib/pterodactyl"
            "custom"
        )
        
        echo "Select data directory location:"
        select opt in "${options[@]}"; do
            case $opt in
                "/home/daemon-data/var/lib/pterodactyl")
                    DATA_DIR="/home/daemon-data/var/lib/pterodactyl"
                    break
                    ;;
                "/var/lib/pterodactyl")
                    DATA_DIR="/var/lib/pterodactyl"
                    break
                    ;;
                "custom")
                    read -p "Enter custom directory path: " DATA_DIR
                    break
                    ;;
                *) 
                    echo "Invalid option"
                    ;;
            esac
        done
    else
        DATA_DIR="/var/lib/pterodactyl"
    fi
    
    # Create data directory
    mkdir -p "${DATA_DIR}/volumes"
    
    success "Data directory setup complete: ${DATA_DIR}"
}

# Create systemd service
create_systemd_service() {
    notice "Creating Wings systemd service..."
    
    cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable Wings
    systemctl daemon-reload
    systemctl enable wings
    
    success "Wings service created and enabled"
}

# Main installation function
main() {
    clear
    echo "============================================================================"
    echo "WPA-ToolBox Wings Installation"
    echo "============================================================================"
    
    # Initialize progress tracking
    echo "0" > "$progress_file"
    
    check_compatibility
    echo "1" > "$progress_file"
    
    install_docker
    echo "2" > "$progress_file"
    
    configure_swap
    echo "3" > "$progress_file"
    
    install_wings
    echo "4" > "$progress_file"
    
    setup_data_directory
    echo "5" > "$progress_file"
    
    create_systemd_service
    echo "6" > "$progress_file"
    
    # Cleanup
    rm -f "$progress_file"
    
    success "Wings installation completed successfully!"
    notice "Please configure your node in the Pterodactyl Panel and copy the configuration to /etc/pterodactyl/config.yml"
    notice "Then start Wings using: systemctl start wings"
    
    # Offer to start Wings
    echo "Starting Wings..."
    systemctl start wings
    notice "Wings service started"
    fi
}

# Execute main installation
main "$@"