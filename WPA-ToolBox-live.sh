#!/bin/bash
#WPA:2.1.1
full_script_name="$0"
script_name=$(basename "$full_script_name")
clear
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_ORANGE='\033[0;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'
success() {
  echo ""
  echo -e "* ${COLOR_GREEN}SUCCESS${COLOR_NC}: $1" 1>&2
  echo ""
}
error() {
  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1" 1>&2
  echo ""
}
warning() {
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1" 1>&2
  echo ""
}
notice() {
  echo ""
  echo -e "* ${COLOR_BLUE}NOTICE${COLOR_NC}: $1" 1>&2
  echo ""
}
# Welcome Boot Screen

sleep 0.2s
echo "============================================================================"
sleep 0.2s
echo "WemxPRO | WPA ToolBox EXPERIMENTAL Script"
sleep 0.2s
echo
sleep 0.2s
echo "Copyright (C) 2021 - $(date +%Y), NekoHosting LLC"
sleep 0.2s
echo "https://github.com/VanillaChan6571/WemxProAuto"
sleep 0.2s
echo
sleep 0.2s
echo "============================================================================"
sleep 0.2s
notice "Running Script Boot Checks... May take a bit.. Please Wait.."
sleep 1s
#Checks if Root is Running SH#
sleep 5s
if [[ $EUID -ne 0 ]] && [[ "$1" != "-ignore-root-only-cause-i-am-dumb" ]]; then
   echo "Oops! You did not run this as ROOT; Sudo does cannot override the locked files sometimes, ROOT modifies the files no matter if locked or not."
   notice "If you wish to continue without ROOT and its special powers (This will likely install will fail or incomplete the install) You can add the following flag: -ignore-root-only-cause-i-am-dumb"
   sleep 5s
   exit 1
fi
clear
#Start of New Show Menu#
#### This is what the user should see First owo
# Menu functions
function show_menu() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox Script 2.1.1 EXPERIMENTAL - Main Menu"
    echo "============================================================================"
    echo

    echo "Select the type of installation:"
    options=("Install" "UpdateWemx" "RenewCert" "UserCreate" "MakeMyDBPublic" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install")
                show_install_menu
                ;;
            "UpdateWemx")
                echo "Updating Wemx Confirmed! | Preparing..."
				sleep 5s
                update_wemx
                ;;
            "RenewCert")
                echo "Proceeding with renewing certificates..."
                sudo certbot renew
                read -p "Press enter to continue..."
                show_menu
                ;;
            "UserCreate")
                show_user_create_menu
                ;;
            "MakeMyDBPublic")
                echo "Performing MakeMyDBPublic..."
                # Add your MakeMyDBPublic logic here
                read -p "Press enter to continue..."
                show_menu
                ;;
            "Quit")
                echo "Exiting..."
                exit 0
                ;;
            *) 
                # Check for the secret key combination
                if [[ $REPLY == "DEV_DEBUG_ME" ]]; then
                    # Call the function for the hidden menu
                    show_hidden_menu
                else
                    echo "Invalid option. Please try again."
                fi
                ;;
        esac
    done
}

# Function for the hidden menu
function show_hidden_menu() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox - DEBUG MENU "
	warning "If you do not know what your doing, then this isn's the correct area for you."
    echo "============================================================================"
	echo 
    echo "DEBUG_JUMP_TO_CERTAIN_AREAS:"
    options=("Full Install" "Admin User Create DB" "DB Node Install" "Full Install DB" "Full Install Continue" "Full Certbot SSL" "Full Web Server" "Full Wings" "Wings Finalize" "Wemx Install" "Adminuser Create DB Wemx" "Wemx Install DB" "Ask MySQL Secure" "MySQL Secure" "Wemx Install Continue" "Finish Installing" "Fresh Boot" "Skip Fresh Boot" "Reboot From Start" "Quit" "Back" "SOW")
    select opt in "${options[@]}"
    do
        case $opt in
			"Full Install")
				read -p "Are you sure you want to proceed with Full Install? (y/n): " confirm
				if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
					echo "Proceeding..."
					full_install
				else
					echo "Canceled."
				fi
				break
				;;
            "Admin User Create DB")
                echo "Proceeding..."
                adminuser_create_db
                break
                ;;
            "DB Node Install")
                echo "Proceeding..."
                db_node_install
                break
                ;;
            "Full Install DB")
                echo "Proceeding..."
                full_install_db
                break
                ;;
            "Full Install Continue")
                echo "Proceeding..."
                full_install_continue
                break
                ;;
            "Full Certbot SSL")
                echo "Proceeding..."
                full_certbot_ssl
                break
                ;;
            "Full Web Server")
                echo "Proceeding..."
                full_web_server
                break
                ;;
            "Full Wings")
                echo "Proceeding..."
                full_wings
                break
                ;;
            "Wings Finalize")
                echo "Proceeding..."
                wings_finalize
                break
                ;;
            "Wemx Install")
                echo "Proceeding..."
                wemx_install
                break
                ;;
            "Adminuser Create DB Wemx")
                echo "Proceeding..."
                adminuser_create_db_wemx
                break
                ;;
            "Wemx Install DB")
                echo "Proceeding..."
                full_install_db_wemx
                break
                ;;
            "Ask MySQL Secure")
                echo "Proceeding..."
                mysql_secure_question
                break
                ;;
            "MysSQL Secure")
                echo "Proceeding..."
                mysql_secure
                break
                ;;
            "Wemx Install Continue")
                echo "Proceeding..."
                wemx_install_continue
                break
                ;;
            "Finish Installing")
                echo "Proceeding..."
                finish_install
                break
                ;;
            "Fresh Boot")
                echo "Proceeding..."
                fresh_boot
                break
                ;;
            "Skip Fresh Boot")
                echo "Proceeding..."
                skip_fresh_boot
                break
                ;;
			"Reboot From Start")
				echo "Proceeding..."
				main
				;;		
            "Back")
                show_menu
                ;;
			"SOW")
				select_option_webserver
				;;
			"Quit"|"Exit")
				echo "Exiting..."
				exit 0
				;;			
            *) echo "Invalid option. Please try again.";;
        esac
    done
}
#-- Sub Menus Actions --#
wemx_update() {
clear
cd /var/www/wemx

COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-web

chmod -R 755 storage/* bootstrap/cache

COMPOSER_ALLOW_SUPERUSER=1 composer update
COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader

php artisan module:enable

php artisan view:clear && php artisan config:clear

php artisan migrate --seed --force

chown -R www-data:www-data /var/www/wemx/*

php artisan wemx:install 2>temp_error.log

#### Retry mechanism
retry_count=0
max_retries=3

while (( retry_count < max_retries )); do
    # Check for the specific error message in the output
    if grep -q "End-of-central-directory signature not found" temp_error.log; then
        # Increment the retry count
        (( retry_count++ ))
    
        # Output a warning message
        warning "Install command failed. Retrying... (Attempt $retry_count of $max_retries)"
    
        # Retry the php artisan command and redirect output to temporary file
        php artisan wemx:install 2>temp_error.log
    else
        # Break out of the loop if no error message is found
        break
    fi
done

# Check if the maximum number of retries was reached
if (( retry_count == max_retries )); then
    error "Installation failed after $max_retries attempts. Exiting..."
    # Cleanup temporary file
    rm temp_error.log
    show_menu
fi

# Cleanup temporary file
rm temp_error.log

#If your reading this, you can technically use the following:
#php artisan wemx:install WEMX-YOURKEYHERE--eula=yes

chmod -R 755 storage/* bootstrap/cache

COMPOSER_ALLOW_SUPERUSER=1 composer update
COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader

php artisan module:update

php artisan module:enable

php artisan view:clear && php artisan config:clear

php artisan migrate --seed --force

chown -R www-data:www-data /var/www/wemx/*

success "Update Completed. Check for Errors Above!"
echo "============================================================================"
echo "This was the entire Auto Updater!"
echo "Returning to Main Meuu... Please Wait..."
echo "============================================================================"
sleep 5s
clear
echo "============================================================================"
success "Successfully ran the Wemx Update Script."
show_menu
}

function show_install_menu() {
    clear
	echo "============================================================================"
	echo "WemxPRO | WPA ToolBox Script 2.1.1 EXPERIMENTAL - Install Menu"
	echo "============================================================================"
	echo 
    echo "Select the type of installation:"
    options=("Full" "Wemx" "Back")
    select opt in "${options[@]}"
    do
        case $opt in
            "Full")
                echo "Proceeding with Full Install..."
                echo "Continuing..."
                warning "Control + C to cancel the install now! Or wait 10 seconds..."
                sleep 10s
                full_install
                break
                ;;
            "Wemx")
                echo "Proceeding with Wemx + DB Only Install..."
                echo "Continuing..."
                sleep 10s
                wemx_install
                break
                ;;
            "Back")
                show_menu
                ;;
            *) echo "Invalid option. Please try again.";;
        esac
    done
}

function certbot_menu() {
    clear
    echo "============================================================================"
    echo "WemxPRO | WPA ToolBox Script 2.1.1 EXPERIMENTAL - Certbot Menu"
    echo "============================================================================"
    echo 
    echo "Select the type of installation:"
    options=("Renew" "Add" "Delete" "Back")
    select opt in "${options[@]}"
    do
        case $opt in
            "Renew")
                echo "Renewing Certbot... Please Wait..."
                sudo certbot renew
                success "Script Completed. Check for Errors Above!"
                echo "============================================================================"
                echo "This was the entire Certbot Script!"
                echo "Returning to Main Menu... Please Wait..."
                echo "============================================================================"
                sleep 5s
                clear
                echo "============================================================================"
                success "Successfully ran the [RENEW] Certbot Script."
                show_menu
                break
                ;;
            "Add")
                echo "Adding A Domain w/ Certbot... | Please Wait..."
                sleep 3s
                clear
                echo "Enter your DOMAIN that will be challenged for certbot."
                read -p "Example, NekoHosting's WemX Domain is nekohosting.gg | DOMAIN/URL: " CERTBOT_ADD_MENU
                sudo systemctl stop nginx
                sudo systemctl stop apache2 # I don't know, but sometimes apache2 is installed for no reason.
                sudo service apache2 stop
                sudo service nginx stop
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9	
                select_menu_add_certbot
                ;;
            "Delete")
                echo "Deleting a domain from Certbot... | Please Wait..."
                sudo certbot delete
                success "Script Completed. Check for Errors Above!"
                echo "============================================================================"
                echo "This was the entire Certbot Script!"
                echo "Returning to Main Menu... Please Wait..."
                echo "============================================================================"
                sleep 5s
                clear
                echo "============================================================================"
                success "Successfully ran the [REMOVE] Certbot Script."
                break
                ;;
            "Back")
                show_menu
                ;;
            *) echo "Invalid option. Please try again.";;
        esac
    done
}

function select_menu_add_certbot() {
    options=("DNS challenge" "HTTP challenge Standalone (Recommend)" "Cancel Script and exit")
    echo "Choose a command to run:"
    echo "============================================================================"
    local choice
    local index=1
    for item in "${options[@]}"; do
        echo "$((index++)). $item"
    done
    echo "============================================================================"
    read -p "Enter your choice [1-$((index-1))]: " choice
    case $choice in
        1)
            sudo systemctl stop nginx
            sudo systemctl stop apache2
            sudo service apache2 stop
            sudo service nginx stop
            sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
            sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
            sudo certbot -d $CERTBOT_ADD_MENU --manual --preferred-challenges dns certonly
            ;;
        2)
            sudo systemctl stop nginx
            sudo systemctl stop apache2
            sudo service apache2 stop
            sudo service nginx stop
            sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
            sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
            sudo certbot certonly --standalone -d $CERTBOT_ADD_MENU
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid option. Please try again."
            select_menu_option_certbot
            ;;
    esac
    success "Script Completed. Check for Errors Above!"
    echo "============================================================================"
    echo "This was the entire Certbot Script!"
    echo "Returning to Main Menu... Please Wait..."
    echo "============================================================================"
    sleep 5s
    clear
    echo "============================================================================"
    success "Successfully ran the [ADD] Certbot Script."
    show_menu
}

function MakeMyDBPublic() {
    echo "Performing MakeMyDBPublic..."
    echo "Changing Database Binding Address to 0.0.0.0 This will allow remote connections to your DB..."
    warning "IF you do not wish to change the Binding Address, Control + C to cancel the changes! or wait 10 seconds to continue..."
    echo "installing MariaDB 11.1... please wait..."
    sleep 2s

    # Detect the Ubuntu version
    version=$(lsb_release -rs)
    # Match the version to its codename
    case $version in
        18.04) codename="bionic" ;;
        20.04) codename="focal" ;;
        22.04) codename="jammy" ;;
        22.10) codename="kinetic" ;;
        23.04) codename="lunar" ;;
        23.10) codename="mantic" ;;
        *)     codename="jammy" ;; # default to jammy for unknown versions
    esac
    echo "Detected Ubuntu Version: $version ($codename)"

    # Install apt-transport-https and curl
    sudo apt-get update
    sudo apt-get install -y apt-transport-https curl

    # Setup the MariaDB repository
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

    # Create the mariadb.sources file
    sudo tee /etc/apt/sources.list.d/mariadb.sources > /dev/null <<EOF
# MariaDB 11.1 repository list [2024]
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
# deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
# URIs: https://deb.mariadb.org/11.1/ubuntu
URIs: https://mirrors.xtom.com/mariadb/repo/11.1/ubuntu
Suites: $codename
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
EOF

    # Update the package lists
    sudo apt-get update
    # Install MariaDB server
    sudo apt-get install -y mariadb-server
    echo "MariaDB installation has been completed."
    sleep 3s
    clear

    notice "Adding 'add-apt-repository' command..."
    sudo apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
    notice "Adding additional repositories for PHP, Redis, and MariaDB..."
    sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    notice "Adding Redis official APT repository..."
    sudo curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    warning "You should manually run 'sudo curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash' since 20.04 or lower is not supported for this script."
    notice "Updating Packages..."
    sudo apt update && sudo apt upgrade -y
    warning "You should manually run 'sudo apt-add-repository universe' since 18.04 is not supported for this script."
    sudo apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server mariadb-client net-tools
	#sudo apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server mariadb-client net-tools
    #WemX Dev Currently is switching to PHP 8.3 + Laravel 11 | This will be updated to mixin 8.1 + 8.3
	sleep 10s

    CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
    if grep -q "^bind-address" $CONFIG_FILE; then
        sudo sed -i '/^bind-address/c\bind-address = 0.0.0.0' $CONFIG_FILE
    else
        # bind-address does not exist, so append it
        echo "bind-address = 0.0.0.0" | sudo tee -a $CONFIG_FILE > /dev/null
    fi

    # Restart MariaDB to apply changes
    sudo systemctl restart mariadb
    # Optional: Confirm bind-address change
    echo "bind-address updated to 0.0.0.0 and MariaDB restarted."
    sleep 2s
    full_install
}

function wemx_install() {
    # Add your Wemx installation logic here
    echo "Performing Wemx installation..."
    cd /var/www/wemx
    notice "Wemx Installer will be run in this setup. We will need the key for it to work."
    read -p "Enter the License Key for WEMX: " WEMX_KEY
    notice "If you wish to not always enter your license key, edit this script to find out more!"
    COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-web
    php artisan wemx:install $WEMX_KEY
    chmod -R 755 storage/* bootstrap/cache
    chown -R www-data:www-data /var/www/wemx/*
    COMPOSER_ALLOW_SUPERUSER=1 composer update
    COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader
    php artisan module:enable
    php artisan view:clear && php artisan config:clear
    php artisan migrate --seed --force
    php artisan module:publish
    chown -R www-data:www-data /var/www/wemx/*
    notice "Clearing the WEMX KEY variable from memory..."
    unset WEMX_KEY
    success "Unsetting for security reasons..."
    success "Done & Cleared!"
    success "Script Complete"
    show_menu
}

function show_user_create_menu() {
    clear
    echo "Select the type of user to create:"
    options=("WemxUser" "PterodactylUser" "Back")
    select opt in "${options[@]}"
    do
        case $opt in
            "WemxUser")
                echo "Proceeding with creating Wemx user..."
                cd /var/www/wemx
                php artisan user:create
                read -p "Press enter to continue..."
                show_menu
                ;;
            "PterodactylUser")
                echo "Proceeding with creating Pterodactyl user..."
                cd /var/www/pterodactyl
                php artisan p:user:make
                read -p "Press enter to continue..."
                show_menu
                ;;
            "Back")
                show_menu
                ;;
            *) echo "Invalid option. Please try again.";;
        esac
    done
}

# -- FULL/SEMI INSTALL --#
full_install() {
    # Installing Composer
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

    # Make Directory
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl

    # Download Files
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/

    # Installation
    clear
    sleep 2s
    echo "Please note that you can skip the Database Setup if you are just purely reinstalling pterodactyl files."
	echo "Please DO CONTINUE to the Database Setup if your doing this the FIRST TIME!!"

    options=("Continue to database installation" "Skip database setup")

    select_option() {
        echo "Do you wish to continue to database installation?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Entering Database Setup for Pterodactyl..."
                adminuser_create_db
                ;;
            2)
                echo "Skipping Database Setup for Pterodactyl, assuming you already have a database for pterodactyl..."
                full_install_continue
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option
                ;;
        esac
    }

    select_option
}
# -- Database Creation -- #
adminuser_create_db() {
    clear
    echo "Creating a Super Admin Account for MariaDB..."
    sleep 3s
    echo " "
    read -p "Enter the desired username for the 'super admin' account (e.g., superadmin): " SUPERADMIN_USER
    echo " "
    read -sp "Enter a password for the new admin account: '$SUPERADMIN_USER' (password): " SUPERADMIN_PASS
    echo "" # for new line after password input

    # Create 'superadmin' user with all privileges
    # Using sudo for MariaDB 10.4 and above
    # Quoting and escaping SQL data
    if sudo mariadb -u root <<EOF
CREATE USER '$SUPERADMIN_USER'@'%' IDENTIFIED BY '$(echo $SUPERADMIN_PASS | sed 's/[\\"$]/\\&/g')';
GRANT ALL PRIVILEGES ON *.* TO '$SUPERADMIN_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    then
        success "Successfully created '$SUPERADMIN_USER' account. Use this account for administrative tasks instead of 'root'."
        notice "Unsetting User and Password from memory for security reasons..."
        unset SUPERADMIN_USER SUPERADMIN_PASS
        sleep 2s
        full_install_db
    else
        error "There was an error creating the '$SUPERADMIN_USER' account. Please check and try again."
        # Print the last few lines of the MariaDB error log for troubleshooting
        sudo tail -n 10 /var/log/mysql/error.log
        notice "Unsetting User and Password from memory for security reasons..."
        unset SUPERADMIN_USER SUPERADMIN_PASS
        sleep 5s
        sudo service mysql start
        notice "Attempting to start MySQL Service if offline during the update process..."
        warning "If you continue to get this loop, something is wrong with your DB Setup. Please reinstall your DB/MySQL..."
        adminuser_create_db
    fi
}
#-------------#
db_node_install(){
sleep 3s
clear
notice "Attempting to create nekouser account..."
notice "Since you made a 'SUPER ADMIN ACCOUNT' please use that instead of root!"
sleep 2s
echo "TIP: for localhost just use localhost or 127.0.0.1, this is for users who have cPanel or weird complex setups."
read -p "Enter the hostname or IP address of the MySQL server (Exmaple: 127.0.0.1 or 5.55.555.5): " DB_HOST
echo " "
read -p "Enter the MySQL root or super_admin username: " ROOT_USER
echo " "
read -sp "Enter the MySQL root or super_admin password: " ROOT_PASSWORD
echo " "
read -sp "Enter the new password for new user of "dbclient": " USERDB_NEW_PASSWORD
echo " "
warning "If Your using root and Root's Password is BLANK then it will ask for a password, just hit enter if blank."
sleep 3s
mysql -h$DB_HOST -u$ROOT_USER -p$ROOT_PASSWORD <<EOF
CREATE USER 'dbclient'@'%' IDENTIFIED BY '$USERDB_NEW_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'dbclient'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
notice "If you're seeing this without any errors from MySQL, your account was created successfully."
notice "You can safely ignore the following warnings: "mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead""
sleep 6s
notice "Clearing the passwords variables from memory..."
unset ROOT_PASSWORD USERDB_NEW_PASSWORD
success "Unsetting for security reasons.."
sleep 3s
success "Done & Cleared!"
sleep 2s
clear
notice "We have success/attempted to created accounts of (panel and dbclient)"
echo "Continuing With Pterodactyl Install..."
sleep 5s
full_install_continue
}
#-----#
full_install_db() {
    sleep 3s
    clear

    notice "Attempting to create panel database..."
    notice "Since you made a 'SUPER ADMIN ACCOUNT', please use that instead of root!"
    sleep 2s

    echo "TIP: For localhost, just use localhost or 127.0.0.1. This is for users who have cPanel or complex setups."
    read -p "Enter the hostname or IP address of the MySQL server (Example: 127.0.0.1 or 5.55.555.5): " DB_HOST
    echo " "
    read -p "Enter the MySQL root or super_admin username: " ROOT_USER
    echo " "
    read -sp "Enter the MySQL root or super_admin password: " ROOT_PASSWORD
    echo " "
    read -sp "Enter the new password for the new user 'panel': " PANEL_NEW_PASSWORD
    echo " "

    warning "If you're using root and the root password is BLANK, it will ask for a password. Just hit enter if blank."
    echo " "
    sleep 3s

mysql -h$DB_HOST -u$ROOT_USER -p$ROOT_PASSWORD <<EOF
CREATE USER 'panel'@'%' IDENTIFIED BY '$PANEL_NEW_PASSWORD';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON *.* TO 'panel'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    notice "If you're seeing this without any errors from MySQL, your account was created successfully."
	notice "You can safely ignore the following warnings: "mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead""
    sleep 6s

    notice "Clearing the password variables from memory..."
    unset ROOT_PASSWORD PANEL_NEW_PASSWORD
    success "Unsetting for security reasons..."
    sleep 3s
    success "Done & Cleared!"
    sleep 2s
    clear

    options=("Yes, create a HOST DB [dbclient] for my node(s)" "No, continue with Pterodactyl installation")

    select_option() {
        notice "Hosting a DB account separately from your pterodactylpanel account is better for security."
        echo "Do you wish to create a HOST DB [dbclient] for your node(s)?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Yes, will make a user named dbclient."
                db_node_install
                ;;
            2)
                notice "We have successfully created/attempted to create the 'panel' account."
                echo "Continuing with Pterodactyl installation..."
                sleep 5s
                full_install_continue
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option
                ;;
        esac
    }

    select_option
}
# -- Continue -- #
full_install_continue() {
    clear
    cd /var/www/pterodactyl

    date=$(date "+%Y%m%d_%H%M%S")

    # Fail Safe, Just in case you ran this twice for whatever reason.
    cp .env .env.old_$date
    cp .env.example .env

    notice "We have copied your .env file if it existed to .env.old_X, no worries of losing your encryption keys!"
    notice "If you get '.env': No such file or directory, safely ignore since there wasn't one to copy."
    sleep 3s

    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

    # Environment Configuration
    clear

    warning "Only run the key generation if you are installing pterodactyl for the first time!!"
    notice "If you're installing for the first time, you will enter YES; otherwise, No."
    warning "This can cause MAC Invalid Issue if you're running it a second time!!"

    options=("Yes, generate a new key" "No, skip key generation")

    select_option_key() {
        echo "Do you want to generate a new key?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                warning "RUNNING THE KEY GENERATE!!"
                php artisan key:generate --force
                ;;
            2)
                echo "Skipping key generation."
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_key
                ;;
        esac
    }

    select_option_key

    echo "Running.. php artisan p:environment:setup"
    sleep 5s
    php artisan p:environment:setup

    echo "Running.. php artisan p:environment:database"
    sleep 5s
    php artisan p:environment:database

    echo "Running.. php artisan p:environment:mail"
    notice "To use PHP's internal mail sending (not recommended), select 'mail'. To use a custom SMTP server, select 'smtp'."
    sleep 5s
    php artisan p:environment:mail

    sleep 3s

    # Database Setup
    php artisan migrate --seed --force

    # Add The First User
    php artisan p:user:make

    # Set Permissions
    chown -R www-data:www-data /var/www/pterodactyl/*

    echo "Stopping Web Servers if any..."
    sudo systemctl stop apache2
    sudo systemctl stop nginx

    clear

    # Queue Listeners
    # Check if the cron job already exists in root's crontab
    cron_exists=$(sudo crontab -l -u root | grep -q 'php /var/www/pterodactyl/artisan schedule:run'; echo $?)

    # If it doesn't exist, add it
    if [ "$cron_exists" -ne 0 ]; then
        # Add the cron job to the root user's crontab
        (sudo crontab -l -u root 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | sudo crontab -u root -
        notice "Cron job added to root's crontab!"
    else
        warning "Cron job already exists in root's crontab!"
    fi

    # Adding Service of Pterodactyl
    sleep 2s

    cat <<EOL > /etc/systemd/system/pteroq.service
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

    # Enabling Redis on System
    sudo systemctl enable --now redis-server

    # Enabling Pterodactyl on System
    sudo systemctl enable --now pteroq.service

    echo " "
    echo " "
    echo " "
    sleep 3s
    clear

    options=("Yes, setup webserver + SSL for Pterodactyl" "No, skip webserver + SSL setup")

    select_option_ssl() {
        echo "Do you want to setup webserver + SSL for Pterodactyl?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Will make webserver + SSL for Pterodactyl..."
                sleep 3
                full_certbot_ssl
                ;;
            2)
                echo "Skipping webserver + SSL for Pterodactyl..."
                sleep 3
                full_install_continue
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_ssl
                ;;
        esac
    }

    select_option_ssl
}
#-----#
full_certbot_ssl() {
    warning "We will be using and running SSL Version of Installation; otherwise, you will need to cancel and manually make your own WEBSERVER."
    warning "Continuing in 15 Seconds... This is your only warning."
    sleep 15s

    notice "Installing Certbot for SSL..."
    sudo apt install -y certbot

    clear

    echo "Enter your DOMAIN that will be challenged for certbot."
    read -p "Example, NekoHosting's Pterodactyl Domain is beta.nekohosting.gg | DOMAIN/URL: " FULL_DOMAIN_URL

    sudo systemctl stop nginx
    sudo systemctl stop apache2 # I don't know, but sometimes apache2 is installed for no reason.
    sudo service apache2 stop
    sudo service nginx stop
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9

    options=("DNS challenge" "HTTP challenge Standalone (Recommend)" "Cancel Script and exit")

    select_option_certbot() {
        echo "Choose a command to run:"
        echo "============================================================================"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        echo "============================================================================"
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                sudo systemctl stop nginx
                sudo systemctl stop apache2
                sudo service apache2 stop
                sudo service nginx stop
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo certbot -d $FULL_DOMAIN_URL --manual --preferred-challenges dns certonly
                ;;
            2)
                sudo systemctl stop nginx
                sudo systemctl stop apache2
                sudo service apache2 stop
                sudo service nginx stop
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo certbot certonly --standalone -d $FULL_DOMAIN_URL
                ;;
            3)
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_certbot
                ;;
        esac
    }

    select_option_certbot

    notice "If any issues, recommend looking at docs for certbot: https://pterodactyl.io/tutorials/creating_ssl_certificates.html#auto-renewal"
    sleep 5s

    notice "Clearing the variables from memory..."
    success "Unsetting for security reasons..."
    success "Done & Cleared!"

    full_web_server
}
#----#
full_web_server() {
    rm /etc/nginx/sites-enabled/default

    AVAILABLE_CONFIG="/etc/nginx/sites-available/pterodactyl.conf"
    ENABLED_CONFIG="/etc/nginx/sites-enabled/pterodactyl.conf"

    # Write the configuration to the file
    cat > "$AVAILABLE_CONFIG" <<'EOF'
server_tokens off;

server {
    listen 80;
    server_name <domain>;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name <domain>;

    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration - Replace the example <domain> with your domain
    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag "index, follow";
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
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

    # Replace the placeholder with the actual domain
    sed -i "s/<domain>/$FULL_DOMAIN_URL/g" "$AVAILABLE_CONFIG"

    # If you want to continue with enabling the configuration for Nginx:
    if [ ! -e "$ENABLED_CONFIG" ]; then
        sudo ln -s "$AVAILABLE_CONFIG" "$ENABLED_CONFIG"
    else
        echo "Symbolic link $ENABLED_CONFIG already exists. Skipping link creation."
    fi

    # Test and reload nginx config
    if sudo nginx -t; then
        sudo systemctl reload nginx
    else
        echo "Nginx configuration test failed. Please review your settings."
    fi
	
	clear

    options=("Yes, continue to Wings Installation" "No, skip Wings and move to Wemx Install")

    select_option_wings() {
        echo "Do you wish to continue to Wings Installation?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Will continue to install Wings for Pterodactyl..."
                sleep 3
                echo " "
                full_wings
                ;;
            2)
                echo "Skipping Wings for Pterodactyl... Moving to Wemx Install..."
                sleep 3
                echo " "
                wemx_install
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_wings
                ;;
        esac
    }

    select_option_wings
}
###----###
full_wings() {
    # Check for manufacturer or virtualization type
    MANUFACTURER=$(sudo dmidecode -s system-manufacturer)
    VIRTUALIZATION=$(sudo systemd-detect-virt)

    # Check if OpenVZ, LXC or Virtuozzo is being used
    if [[ $VIRTUALIZATION == "openvz" ]] || [[ $VIRTUALIZATION == "lxc" ]] || [[ $MANUFACTURER == *'Virtuozzo'* ]]; then
        clear
        warning "Your provider uses a virtualization that may not be supported."
        sleep 3
        error "Please refer to the https://pterodactyl.io/wings/1.0/installing.html since your setup does not support wings at this time."
        sleep 2
        exit 1
    elif [[ $VIRTUALIZATION == "none" ]]; then
        success "You are running on dedicated hardware without any virtualization."
        sleep 3
    else
        notice "Your system is not on a dedicated hardware/system. However, we couldn't find (OPENVZ/LXC/Virtuozzo) running, so that's good enough."
        sleep 3
    fi

    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    systemctl enable --now docker

    if docker info 2>&1 | grep -q "WARNING: No swap limit support"; then
        echo "Warning detected: Docker has no swap limit support."
        echo "The Script will not modify the GRUB..."
        sleep 5s
    else
        echo "Docker seems to have swap limit support. Modifying the GRUB..."
        sleep 2s
        notice "CREATING A BACKUP OF GRUB, just for security/safety reasons..."
        # Backup the current GRUB configuration
        sudo cp /etc/default/grub /etc/default/grub.backup
        # Check if the line exists and modify/add it accordingly
        if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
            # Modify the existing line
            sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"/' /etc/default/grub
        else
            # Add the line if it doesn't exist
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"' >> /etc/default/grub
        fi
        # Update GRUB
        sudo update-grub
        # Provide feedback to the user
        echo "GRUB modified successfully. Please reboot the system for changes to take effect."
    fi

    # Installing Pterodactyl Wings
    notice "Installing Pterodactyl Wings..."
    mkdir -p /etc/pterodactyl
    # Determine architecture and download the appropriate version of wings
    ARCH=$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH"
    chmod u+x /usr/local/bin/wings

    # Warning for OVH/SYS Servers
    if df -h | grep -q '/home'; then
        warning "It seems you might be using an OVH/SYS server. The main drive space might be allocated to /home. Consider using /home/daemon-data for server data when setting up the node."
    fi

    mkdir /etc/pterodactyl/
    touch /etc/pterodactyl/config.yml

    notice "Making a Daemon Server File Directory..."
    echo "If you use OVH, you should check your partition scheme. You may need to use /home/daemon-data to have enough space."

    options=("Default Location" "Custom Location" "Default Location (OVH)" "Custom Location (OVH)" "Cancel Script and Exit")

    select_option() {
        echo "Select an option:"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                cd /
                mkdir -p /var/lib/pterodactyl/volumes
                notice "Configuration File you will need to add manually from the panel itself."
                sleep 10
                wings_finalize
                ;;
            2)
                read -p "Enter Custom Directory Name: " DIR_CUSTOMKEY
                cd /
                mkdir -p /$DIR_CUSTOMKEY/volumes
                notice "Configuration File you will need to add manually from the panel itself."
                sleep 10
                wings_finalize
                ;;
            3)
                cd /
                mkdir -p /home/daemon-data/var/lib/pterodactyl/volumes
                notice "Configuration File you will need to add manually from the panel itself."
                sleep 10
                wings_finalize
                ;;
            4)
                read -p "Enter Custom Directory Name: " DIR_CUSTOMKEY
                cd /home/daemon-data
                mkdir -p /home/daemon-data/$DIR_CUSTOMKEY/volumes
                notice "Configuration File you will need to add manually from the panel itself."
                sleep 10
                wings_finalize
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option
                ;;
        esac
    }

    select_option
}
#---#
wings_finalize(){
clear
# Write the service configuration to the correct location
cat <<EOL > /etc/systemd/system/wings.service
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
EOL

# Reload systemd, enable and start the wings service
systemctl enable --now wings
systemctl daemon-reload
systemctl enable wings.service
systemctl start wings.service

# Check the status
if systemctl is-active --quiet wings.service; then
    success "Pterodactyl Wings service is active and running."
	sleep 3s
	wemx_install
else
    error "There was an issue starting the Pterodactyl Wings service. Please check the service status manually when installer is completed.."
	sleep 3s
	wemx_install
fi
}
#---#
wemx_install() {
    clear
    echo "============================================================================"
    warning "Please review the status of the Pterodactyl and Wings installation."
    warning "If there were any issues, it is recommended to cancel the script and resolve them before proceeding."
    warning "If the installation was successful and you wish to continue, please select 'No' when prompted."
    echo "============================================================================"
    
    options=("No, continue the installer" "Yes, exit the installer")
    
    select_option_continue() {
        echo "Were there any issues during the Pterodactyl and Wings installation?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Continuing..."
                ;;
            2)
                echo "User selected to exit. Attempting to exit..."
                exit
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_continue
                ;;
        esac
    }

    select_option_continue

    notice "Wemx Installer will be run in this setup. We will need the license key for it to work."
    read -p "Enter the License Key for WEMX: " WEMX_KEY
notice "Installing Composer..."
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
cd /var/www
sudo rm -r wemx # This is here due to laravel complain if running again.
notice "Making Directory via laravel..."
COMPOSER_ALLOW_SUPERUSER=1 composer create-project laravel/laravel wemx
cd /var/www/wemx
notice "Downloading the WemX Installer using composer..."
COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-web
warning "You automatically agree to WEMX's EULA."
php artisan wemx:install $WEMX_KEY
# Fail Safe, Just incase you ran this twice for whatever reason.
cp .env .env.old_$date
cp .env.example .env
notice "We have copied your .env file if existed to .env.old_X, no worries of losing your encryption keys!"
notice "if you get '.env': No such file or directory, safely ignore since there wasn't one to copy."
sleep 5s
clear
#For Whatever reason, Wemx own installer doesn't do This
COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-web
chmod -R 755 storage/* bootstrap/cache
COMPOSER_ALLOW_SUPERUSER=1 composer update
COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader
php artisan module:enable
php artisan view:clear && php artisan config:clear
php artisan migrate --seed --force
php artisan module:publish
chown -R www-data:www-data /var/www/wemx/*
COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader
notice "Clearing the WEMX KEY variable from memory..."
warning "You automatically agree to WEMX's EULA."
php artisan wemx:install $WEMX_KEY
# Fail Safe, Just incase you ran this twice for whatever reason.
cp .env .env.old_$date
cp .env.example .env
notice "We have copied your .env file if existed to .env.old_X, no worries of losing your encryption keys!"
notice "if you get '.env': No such file or directory, safely ignore since there wasn't one to copy."
unset WEMX_KEY
success "Unsetting for security reasons.."
success "Done & Cleared!"
    echo "============================================================================"
    warning "Please review the status of the pre-install-wemx process."
    warning "If there were any issues, it is recommended to cancel the script and resolve them before proceeding."
    warning "If the pre-install-wemx process was successful and you wish to continue, please select 'Yes' when prompted."
    echo "============================================================================"

    options=("Yes, continue to the database installation for Wemx" "No, exit the installer")

    select_option_db() {
        echo "Do you wish to continue to the database installation for Wemx?"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Continuing..."
                while true; do
                    clear
                    notice "If you already created a Super Admin Account during the Pterodactyl installation, you can use that existing account."
                    notice "If you skipped the Pterodactyl database setup, it is recommended to create a new Super Admin Account."
                    
                    options=("Yes, Use an existing Super Admin Account" "No, Create a new Super Admin Account")

                    select_option_admin() {
                        echo "Do you already have a Super Admin Account that's not root?"
                        local choice
                        local index=1
                        for item in "${options[@]}"; do
                            echo "$((index++)). $item"
                        done
                        read -p "Enter your choice [1-$((index-1))]: " choice
                        case $choice in
                            1)
                                echo "Proceeding with the assumption that a Super Admin Account already exists..."
                                full_install_db_wemx
                                break 2
                                ;;
                            2)
                                echo "Proceeding to create a new Super Admin Account..."
                                adminuser_create_db_wemx
                                break 2
                                ;;
                            *)
                                echo "Invalid option. Please try again."
                                select_option_admin
                                ;;
                        esac
                    }

                    select_option_admin
                done
                ;;
            2)
                echo "User selected to exit. Attempting to exit..."
                exit
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_db
                ;;
        esac
    }

    select_option_db
}
#-----#
adminuser_create_db_wemx() {
    clear
    echo "Creating a Super Admin Account for MariaDB..."
    sleep 3s
    echo " "
    read -p "Enter the desired username for the 'super admin' account (e.g., superadmin): " SUPERADMIN_USER
    echo " "
    read -sp "Enter a password for the new admin account: '$SUPERADMIN_USER' (password): " SUPERADMIN_PASS
    echo "" # for new line after password input

    # Create 'superadmin' user with all privileges
    # Using sudo for MariaDB 10.4 and above
    # Quoting and escaping SQL data
    if sudo mariadb -u root <<EOF
CREATE USER '$SUPERADMIN_USER'@'%' IDENTIFIED BY '$(echo $SUPERADMIN_PASS | sed 's/[\\"$]/\\&/g')';
GRANT ALL PRIVILEGES ON *.* TO '$SUPERADMIN_USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    then
        success "Successfully created '$SUPERADMIN_USER' account. Use this account for administrative tasks instead of 'root'."
        notice "Unsetting User and Password from memory for security reasons..."
        unset SUPERADMIN_USER SUPERADMIN_PASS
        sleep 2s
        full_install_db_wemx
    else
        error "There was an error creating the '$SUPERADMIN_USER' account. Please check and try again."
        # Print the last few lines of the MariaDB error log for troubleshooting
        sudo tail -n 10 /var/log/mysql/error.log
        notice "Unsetting User and Password from memory for security reasons..."
        unset SUPERADMIN_USER SUPERADMIN_PASS
        sleep 5s
        sudo service mysql start
        notice "Attempting to start MySQL Service if offline during the update process..."
        warning "If you continue to get this loop, something is wrong with your DB Setup. Please reinstall your DB/MySQL..."
        adminuser_create_db_wemx
    fi
}

full_install_db_wemx() {
    sleep 3s
    clear
    notice "Attempting to create Wemx database..."
    notice "Since you made a 'SUPER ADMIN ACCOUNT', please use that instead of root!"
    sleep 2s
    echo "TIP: For localhost, just use localhost or 127.0.0.1. This is for users who have cPanel or complex setups."
    read -p "Enter the hostname or IP address of the MySQL server (Example: 127.0.0.1 or 5.55.555.5): " DB_HOST
    echo " "
    read -p "Enter the MySQL root or super_admin username: " ROOT_USER
    echo " "
    read -sp "Enter the MySQL root or super_admin password: " ROOT_PASSWORD
    echo " "
    read -sp "Enter the new password for the new user 'wemx': " WEMX_NEW_PASSWORD
    echo " "
    warning "If you're using root and the root password is BLANK, it will ask for a password. Just hit enter if blank."
    echo " "
    sleep 3s

    mysql -h$DB_HOST -u$ROOT_USER -p$ROOT_PASSWORD <<EOF
CREATE USER 'wemx'@'%' IDENTIFIED BY '$WEMX_NEW_PASSWORD';
CREATE DATABASE wemx;
GRANT ALL PRIVILEGES ON *.* TO 'wemx'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    notice "If you're seeing this without any errors from MySQL, your account was created successfully."
	notice "You can safely ignore the following warnings: "mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead""
    sleep 6s
    notice "Clearing the password variables from memory..."
    unset ROOT_PASSWORD WEMX_NEW_PASSWORD
    success "Unsetting for security reasons..."
    sleep 3s
    success "Done & Cleared!"
    sleep 2s
    clear

    mysql_secure_question
}

mysql_secure_question() {
    notice "Attempting to secure MariaDB installation..."

    options=("Yes, secure the MariaDB installation" "No, skip securing the MariaDB installation")

    select_option_secure() {
        echo "Would you like to secure your MariaDB installation? It's recommended."
        notice "If it's already secured, please skip this. 99% of the time, it's never secured on first/fresh installs of the OS."
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                echo "Proceeding to secure the MariaDB installation..."
                mysql_secure
                ;;
            2)
                warning "Skipped securing the MariaDB installation. It's recommended to secure it in the future."
                wemx_install_continue
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_secure
                ;;
        esac
    }

    select_option_secure
}

mysql_secure() {
    notice "Securing MySQL/MariaDB... Please wait..."
    sleep 3s
    mysql_secure_installation
    sleep 2s
    wemx_install_continue
}
#-----#
wemx_install_continue() {
    cd /var/www/wemx
    # End of Securing Database
    notice "Running the 'Setup the environment'"
    sleep 3s
    php artisan setup:environment && php artisan setup:database
    notice "Running the 'Setup database environment'"
    sleep 3s
    php artisan module:enable && php artisan storage:link

    warning "Only run the key generation if you are installing WemX for the first time!!"
    notice "If you're installing for the first time, you will enter YES; otherwise, No."

    options=("Yes, generate a new key" "No, skip key generation")

    select_option_key() {
        echo "Do you want to generate a new key? This can cause MAC Invalid Issue if you're running it a second time!!"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                warning "RUNNING THE KEY GENERATE!!"
                php artisan key:generate --force
                ;;
            2)
                echo "Skipping key generation."
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_key
                ;;
        esac
    }

    select_option_key

    notice "Enable all the default modules and services..."
    php artisan module:enable
    notice "Create a symbolic link from public/storage to storage/app/public"
    php artisan storage:link
    notice "Migrate the database..."
    php artisan migrate --force
    notice "Setting the License key..."
    sleep 3s
    warning "You may need to re-enter/paste the key from WemX again..."
    php artisan license:update
    sleep 2s
    clear
    sudo chown -R www-data:www-data /var/www/wemx/*
    (crontab -l 2>/dev/null; echo "* * * * * php /var/www/wemx/artisan schedule:run >> /dev/null 2>&1") | crontab -
    sleep 3s
    clear

    options=("Import Users" "Create New User" "Exit")

    select_option_user() {
        echo "Choose a command to run:"
        echo "============================================================================"
#        echo "1. If you are migrating over from the previous WemX Billing Module, you can choose to import the users from the old billing module and your Pterodactyl users."
#        echo "The following will be imported: Users, Addresses, Account Balance."
#        warning "1. At this moment, WemX only supports $ USD. If you are using a different currency on the previous version, this might cause some issues. More currency support will be added."
		notice "1. The WemX Billing mirgration is no longer supported in the main setup, please exit and then select "Import Old Billing Users" as its been a couple of years now..."
		warning "Selecting 1 is just selecting 2.."
        echo "2. If you are not migrating over, this creates a new user."
        echo "3. This just stops the script and will not make a user or import a user."
        echo "============================================================================"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                #php artisan import:pterodactyl:users 2>&1 | tee temp_log.txt
                #if grep -q "Table 'wings.billing_users' doesn't exist" temp_log.txt; then
                #    warning "Detected missing table 'wings.billing_users'."
                #    echo "Switching to user creation mode..."
                #    notice "This means that you never had Billing Module V1 or V2 installed before..."
                #    sleep 5s
                php artisan user:create # (Code is still here if you wish to "RE-Enable" it but otherwise its marked as disabled)
                #elif grep -q "Could not connect to the database." temp_log.txt; then
                    #warning "Could not connect to the database."
                    #echo "Please check your database details and try again."
                #elif grep -q "Users table does not exist in the provided database." temp_log.txt; then
                    #echo "Switching to user creation mode..."
                    #notice "This means that you never had Billing Module V1 or V2 installed before or connected to the incorrect database..."
                    #sleep 5s
                    #php artisan user:create
                #fi
                #rm temp_log.txt
                ;;
            2)
                php artisan user:create
                ;;
            3)
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_user
                ;;
        esac
    }

    select_option_user

    clear
    success "Installation of WemX is now 50% completed."
    sleep 5s
    warning "IF YOU NEVER CREATED A USER, RUN 'php artisan user:create' in cd /var/www/wemx"
    sleep 10s
    clear

    echo "============================================================================"
    warning "If there were any issues during the install, please cancel the script!"
    warning "If there were no issues during the install, you may continue the script!"
    echo "============================================================================"

    options=("Yes, automatically configure WEBSERVER/NGINX for WemX" "No, exit the script")

    select_option_webserver() {
      echo "Do you wish to automatically configure your WEBSERVER/NGINX for WemX?"
      local choice
      local index=1
      options=("Yes" "No")  # Declare the options array
      for item in "${options[@]}"; do
        echo "$((index++)). $item"
      done
      read -p "Enter your choice [1-$((index-1))]: " choice
      case $choice in
        1)
          echo "Continuing to WEBSERVER INSTALLATION..."
          ;;
        2)
          echo "Attempting to exit..."
          exit
          ;;
        *)
          # Check for the secret key combination
          if [[ $choice == "DEV_DEBUG_SKIP" ]]; then
            # Call the function for the hidden menu
            select_option_certbot
          else
            echo "Invalid option. Please try again."
            select_option_webserver
          fi
          ;;
      esac
    }

    if [ $? -eq 2 ]; then
        echo "User selected to exit. Attempting to exit..."
        exit
    fi

    warning "We will be using and running SSL Version of Installation; otherwise, you will need to cancel and manually make your own WEBSERVER"
    warning "Continuing in 15 Seconds... This is your only warning."
    sleep 15s
    clear
    echo "Enter your DOMAIN that will be challenged for certbot."
    read -p "Example, NekoHosting's WemX Domain is nekohosting.gg | DOMAIN/URL: " WEMX_DOMAIN_URL
    sudo systemctl stop nginx
    sudo systemctl stop apache2 # I don't know, but sometimes apache2 is installed for no reason.
    sudo service apache2 stop
    sudo service nginx stop
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
    sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9

    options=("DNS challenge" "HTTP challenge Standalone (Recommend)" "Cancel Script and exit")

    select_option_certbot() {
        echo "Choose a command to run:"
        echo "============================================================================"
        local choice
        local index=1
        for item in "${options[@]}"; do
            echo "$((index++)). $item"
        done
        echo "============================================================================"
        read -p "Enter your choice [1-$((index-1))]: " choice
        case $choice in
            1)
                sudo systemctl stop nginx
                sudo systemctl stop apache2
                sudo service apache2 stop
                sudo service nginx stop
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo certbot -d $WEMX_DOMAIN_URL --manual --preferred-challenges dns certonly
                ;;
            2)
                sudo systemctl stop nginx
                sudo systemctl stop apache2
                sudo service apache2 stop
                sudo service nginx stop
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo netstat -tulnep | grep -E ':80|:443' | awk '{print $9}' | cut -d'/' -f1 | xargs sudo kill -9
                sudo certbot certonly --standalone -d $WEMX_DOMAIN_URL
                ;;
            3)
                exit
                ;;
            *)
                echo "Invalid option. Please try again."
                select_option_certbot
                ;;
        esac
    }

    select_option_certbot

    notice "If any issues, recommend looking at docs for certbot: https://pterodactyl.io/tutorials/creating_ssl_certificates.html#auto-renewal"
    sleep 5s
    sudo systemctl start nginx
    sudo service wings stop
    sudo systemctl stop wings

    AVAILABLE_CONFIG="/etc/nginx/sites-available/wemx.conf"
    ENABLED_CONFIG="/etc/nginx/sites-enabled/wemx.conf"

    # Write the configuration to the file
    cat > "$AVAILABLE_CONFIG" <<'EOF'
server {
    listen 80;
    server_name <domain>;
    server_tokens off;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name <domain>;

    root /var/www/wemx/public;
    index index.php;

    access_log /var/log/nginx/wemx.app-access.log;
    error_log  /var/log/nginx/wemx.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration - Replace the example <domain> with your domain
    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag "index, follow";
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
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

    # Replace the placeholder with the actual domain
    sed -i "s/<domain>/$WEMX_DOMAIN_URL/g" "$AVAILABLE_CONFIG"

    # If you want to continue with enabling the configuration for Nginx:
    if [ ! -e "$ENABLED_CONFIG" ]; then
        sudo ln -s "$AVAILABLE_CONFIG" "$ENABLED_CONFIG"
    else
        echo "Symbolic link $ENABLED_CONFIG already exists. Skipping link creation."
    fi

    # Test and reload nginx config
    if sudo nginx -t; then
        sudo systemctl reload nginx
    else
        echo "Nginx configuration test failed. Please review your settings."
    fi

    finish_install
}
#-----#
finish_install(){
sudo systemctl reload nginx
sudo systemctl start nginx
sudo service wings stop
sudo systemctl stop wings
sudo service wings start
sudo systemctl start wings
success "Installation of WEMX & WEBSERVER is now Completed and should be running!"
echo "============================================================================"
echo "This was the entire installer!"
echo "Thank You for using the WemxPROAuto Installer!"
echo "Made by nwya#0 or VanillaChan#6571"
echo "============================================================================"
success "Exited WPA-ToolBox-2.1.1"
exit 0
}
#---#
fresh_boot(){
sleep 3s
#New Version of Script
echo "============================================================================"
echo "New Boot Detected. Executing Pre-Install/Updates... Please wait..."
echo "============================================================================"
sleep 3s
			echo "installing MariaDB 11.1... please wait..."
			# Detect the Ubuntu version
			version=$(lsb_release -rs)
			# Match the version to its codename
			case $version in
				18.04) codename="bionic" ;;
				20.04) codename="focal" ;;
				22.04) codename="jammy" ;;
				22.10) codename="kinetic" ;;
				23.04) codename="lunar" ;;
				23.10) codename="mantic" ;;
				*)     codename="jammy" ;; # default to jammy for unknown versions
			esac
			echo "Detected Ubuntu Version: $version ($codename)"
			# Install apt-transport-https and curl
			sudo apt-get update
			sudo apt-get install -y apt-transport-https curl
			# Setup the MariaDB repository
			sudo mkdir -p /etc/apt/keyrings
			sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
			# Create the mariadb.sources file
			cat << EOF | sudo tee /etc/apt/sources.list.d/mariadb.sources
# MariaDB 11.1 repository list [2024]
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
# deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
# URIs: https://deb.mariadb.org/11.1/ubuntu
URIs: https://mirrors.xtom.com/mariadb/repo/11.1/ubuntu
Suites: $codename
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
EOF
			# Update the package lists
			sudo apt-get update
			# Install MariaDB server
			sudo apt-get install -y mariadb-server
			echo "MariaDB installation has been completed."
			sleep 3s
			clear
			notice "Adding "add-apt-repository" command..."
			sudo apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
			notice "Adding additional repositories for PHP, Redis, and MariaDB..."
			sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
			notice "Adding Redis official APT repository..."
			echo "Adding Redis official APT repository..."
			sudo rm -f /usr/share/keyrings/redis-archive-keyring.gpg
			sudo curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
			warning "You should manually run 'sudo curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash' since 20.04 or lower is not supported for this script."
			sleep 2s
			notice "Updating Packages..."
			sleep 3s
			sudo apt update && sudo apt upgrade -y
			warning "You should manually run 'sudo apt-add-repository universe' since 18.04 is not supported for this script."
			sudo apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server mariadb-client net-tools
			sleep 2s
			echo "============================================================================"
			echo "Pre-install/Update Completed..."
			echo "============================================================================"
			sleep 5s
			clear
			sed -i 's/booted=.*/booted=1/' "$config_file"
			skip_fresh_boot
}
skip_fresh_boot(){
echo "============================================================================"
echo "WemxPRO | WPA ToolBox Script 2.1.1 EXPERIMENTAL"
echo
echo "Copyright (C) 2021 - $(date +%Y), NekoHosting LLC"
echo "https://github.com/VanillaChan6571/WemxProAuto"
echo
echo "============================================================================"
echo "Patch Notes for 2.1.1"
echo "+ New Menu!!"
echo "+ WemxPRO-Installer renamed to WPA-ToolBox "
echo "+ New Options"
echo "+ Add pterodactyl method to auto install first or skip."
echo "+ Marked EXPERIMENTAL "
echo "============================================================================"
echo " "
notice "Showing the New Menu in 10 seconds... please wait..."
sleep 10s
show_menu
}
#Check for Files/Versions
#---#
# Configuration and path variables
config_file="WPA.conf"
VERSION_URL="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/CheckUpdates/VersionCheck.txt"
NEW_SCRIPT_URL="https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WPA-Toolbox-live.sh"
CURRENT_SCRIPT="$(basename "$0")"
TEMP_SCRIPT="new_script.sh"

# Check if WPA.conf exists
check_booted() {
    if [ -f "$config_file" ]; then
        booted=$(grep -oP 'booted=\K\d+' "$config_file")
    else
        echo "booted=0" > "$config_file"
        echo "version=2.1.1" >> "$config_file"
        booted=0
		version=2.1.1
    fi
}
# Fetch version information
get_remote_version() {
    echo $(curl -s $VERSION_URL | grep 'Latest:' | cut -d' ' -f2)
}
get_local_version() {
    echo $(grep 'version=' $config_file | cut -d'=' -f2)
}
# Update script function
update_script() {
    echo "Starting update..."
    curl -s -o "$TEMP_SCRIPT" "$NEW_SCRIPT_URL"
    if [ -s "$TEMP_SCRIPT" ]; then
        chmod +x "$TEMP_SCRIPT"
        mv "$TEMP_SCRIPT" "$CURRENT_SCRIPT"
        echo "The script has been updated successfully."
        update_version_in_config
        echo "The Update was completed. Please Relaunch the script to continue!"
        exit 0
    else
        echo "Failed to download the new script."
        rm -f "$TEMP_SCRIPT"
        echo "Continuing without updating as last resort..."
    fi
}
# Update version in WPA.conf
update_version_in_config() {
    OLD_VERSION=$(get_local_version)
    NEW_VERSION=$(get_remote_version)
    sed -i "s/version=$OLD_VERSION/version=$NEW_VERSION/g" "$config_file"
    echo "Version updated from $OLD_VERSION to $NEW_VERSION."
}
# Main logic for version check and update
main() {
    check_booted
    local_version=$(get_local_version)
    remote_version=$(get_remote_version)
    if [[ "$remote_version" != "$local_version" ]]; then
        echo "============================================================================"
        echo "WemxPRO | WPA ToolBox Script - NEW UPDATE DETECTED! "
        echo "============================================================================"
        echo "Update available: $remote_version. Current version: $local_version."
        echo "Would you like to Update?"
        select opt in "Yes" "No"; do
            case $opt in
                "Yes") update_script;;
                "No") echo "Continuing without updating..."; break;;
                *) echo "Invalid option. Please try again.";;
            esac
        done
    else
        echo "No update needed. Current version: $local_version."
    fi
    # Handle boot logic
    if [ "$booted" -eq 0 ]; then
        fresh_boot
    elif [ "$booted" -eq 1 ]; then
        skip_fresh_boot
    else
        fresh_boot
    fi
}
# Execute main function
main