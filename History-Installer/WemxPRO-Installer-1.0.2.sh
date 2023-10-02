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

echo "============================================================================"
echo "WemxPRO | Wemx Pro INSTALLER Script 1.0.2"
echo
echo "Copyright (C) 2021 - $(date +%Y), NekoHosting"
echo "https://github.com/VanillaChan6571/WemxProAuto"
echo
warning "DO NOT RUN THIS IF YOU ALREADY HAVE A WEMX INSTALLED!"
echo "YOU SHOULD ONLY RUN THIS IF YOU WISH TO DO A NEW INSTALL!"
echo "============================================================================"
echo "Patch Notes for 1.0.1"
echo "- Removed Python3 Nginx. (Seems to not work and caused issues)"
echo "- Removed NGINX Challenge, DNS and HTTP still works."
echo "+ Fixed some typo's and uppercasing."
echo "+ Fixed WEMX Key shouldn't be invisible when typing or pasting."
echo "============================================================================"
echo "Patch Notes for 1.0.2"
echo "- Removed eula=yes. (Removed in 1.7.0 since you automatically agree when you purchase Wemx.)"
echo " "
echo "If you wish to download the older versions, you can on the github"
echo "============================================================================"
#Checks to continue#

while true; do

read -p "ARE YOU SURE YOU WISH TO FRESH INSTALL? [Script: WemxPRO-INSTALLER-1.0.2] (y/N) " yn

case $yn in
	[yY] ) echo Continuing with the NEW INSTALL of WEMX;
		break;;
	[nN] ) echo Exiting...;
		exit;;
	* ) echo Invalid Response;;
esac

done

warning "THE INSTALL WILL START IN 30 SECONDS"
warning "IF YOU DID NOT MEAN TO RUN THE INSTALLER OF WEMX"
warning "PLEASE CANCEL THE SCRIPT BY Control + C"
warning "THIS IS NOT THE WEMX UPDATER!!"
warning "THIS IS YOUR LAST CHANCE TO CANCEL!"

sleep 30s

notice "Adding "add-apt-repository" command..."

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

sudo apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server

echo "============================================================================"
warning "If there was any issues during the pre-install please cancel the script!"
warning "If there was no issues during the pre-install you may contine the script!"
echo "============================================================================"

read -p "Was there any issues during the install? (Y/n) " yn

while true; do

case $yn in
	[nN] ) echo Continuing...;
		break;;
	[yY] ) echo User Selected Yes... Attempting to Exit...;
		exit;;
	* ) echo Invalid Response;;
esac

done

notice "Wemx Installer will be ran in this setup... We will need the key for it to work."

read -p "Enter the License Key for WEMX: " WEMX_KEY

notice "Installing Composer..."

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

cd /var/www
sudo rm -r wemx # This is here due to laravel complain if running again.

notice "Making Directory via laravel..."

COMPOSER_ALLOW_SUPERUSER=1 composer create-project laravel/laravel wemx

cd /var/www/wemx

notice "Downloading the WemX Installer using composer..."

COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-wemxpro

warning "You automatically agree to WEMX's EULA."

php artisan wemx:install $WEMX_KEY

cp .env.example .env

COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader

notice "Clearing the WEMX KEY variable from memory..."
unset WEMX_KEY
success "Unsetting for security reasons.."
success "Done & Cleared!"

echo "============================================================================"
warning "If there was any issues during the pre-install-1 please cancel the script!"
warning "If there was no issues during the pre-install-1 you may contine the script!"
echo "============================================================================"

read -p "Do you wish to continue to database installation? (Y/n) " yn

while true; do

case $yn in
	[yY] ) echo Continuing...;
		break;;
	[nN] ) echo Attempting to Exit...;
		exit;;
	* ) echo Invalid Response;;
esac

done

notice "Attempting to create your databases..."

echo "TIP: for localhost just use localhost or 127.0.0.1, this is for users who have cPanel or weird complex setups."
read -p "Enter the hostname or IP address of the MySQL server (Exmaple: 127.0.0.1 or 5.55.555.5):" DB_HOST
echo " "
read -p "Enter the MySQL root username: " ROOT_USER
echo " "
read -sp "Enter the MySQL root password: " ROOT_PASSWORD
echo " "
read -sp "Enter the new password for wemx: " NEW_PASSWORD
echo " "
read -p "Enter the host for the new user (127.0.0.1 for local only connections, % for any host): " HOST
warning "If Root's Password is BLANK then it will ask for a password, just hit enter if blank."
sleep 3s

mysql -h$DB_HOST -u$ROOT_USER -p$ROOT_PASSWORD <<EOF
CREATE USER 'wemx'@'$HOST' IDENTIFIED BY '$NEW_PASSWORD';
CREATE DATABASE wemx;
GRANT ALL PRIVILEGES ON wemx.* TO 'wemx'@'$HOST' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

notice "Clearing the passwords variables from memory..."
unset ROOT_PASSWORD NEW_PASSWORD
success "Unsetting for security reasons.."
success "Done & Cleared!"

notice "Running the 'Setup the environment'"
sleep 3s
php artisan setup:environment

notice "Running the 'Setup database environment'"
sleep 3s
php artisan setup:database

warning "RUNNING THE KEY GENERATE!!"
php artisan key:generate --force
echo "Only run this command if you are installing WemX for the first time!!"
sleep 3s

notice "Enable all the default modules and services..."
php artisan module:enable

notice "Create a symbolic link from public/storage to storage/app/public"
php artisan storage:link

notice "Migrate the database..."
php artisan migrate --force

notice "Setting the License key..."
sleep 3s
warning "You may will need to re-enter/paste the key from wemx again..."
php artisan license:update

sudo chown -R www-data:www-data /var/www/wemx/*

(crontab -l 2>/dev/null; echo "* * * * * php /var/www/wemx/artisan schedule:run >> /dev/null 2>&1") | crontab -
sleep 3s

echo "Choose a command to run:"
echo "============================================================================"
echo "1. If you are migrating over from the previous Billing Module you can choose to import the users from the old billing module and your pterodactyl users."
echo "1. The following will be imported: Users, Addresses, Account Balance."
warning "1. At this moment, WemX only supports $ USD if you are using a different currency on the previous version, this might cause some issues. More currency support will be added."
echo "2. If you are not migrating over, this makes a new user."
echo "3. This just stops the script and will not make a user or import a user."
echo "============================================================================"
select opt in "1" "2" "3"
do
    case $opt in
        "1")
            php artisan import:pterodactyl:users
            break;;
        "2")
            php artisan user:create
            break;;
        "3")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

success "Installation of WEMX is now Completed"

echo "============================================================================"
warning "If there was any issues during the install please cancel the script!"
warning "If there was no issues during the install you may contine the script!"
echo "============================================================================"

read -p "Do you wish to automatically configure your WEBSERVER/NGINX? (y/N) " yn

while true; do

case $yn in
	[yY] ) echo Continuing to WEBSERVER INSTALLATION...;
		break;;
	[nN] ) echo Attempting to Exit...;
		exit;;
	* ) echo Invalid Response;;
esac

done

warning "We will be using and running SSL Version of Installation otherwise you will need to cancel and manually make your own WEBSERVER"
warning "Continuing in 15 Seconds... This is your only warning."
sleep 15s

notice "Installing Certbot for SSL..."

echo "Choose a command to run:"
echo "============================================================================"
echo "1. sudo apt install -y certbot"
echo "2. cancel script and exit."
echo "There was a third option but it seems that it doesn't work with this setup."
echo "============================================================================"
select opt in "1" "2"
do
    case $opt in
        "1")
            sudo apt install -y certbot
            break;;
        "2")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

read -sp "Enter your DOMAIN that will be challenged (Example: beta.nekohosting.gg): " DOMAIN_URL

sudo systemctl stop nginx
sudo systemctl stop apache2 #I don't know but sometimes apache2 is installed for no reason.

echo "Choose a command to run:"
echo "============================================================================"
echo "1. DNS challenge"
echo "2. HTTP challenge Standalone"
echo "3. Cancel Script and exit."
echo "============================================================================"
select opt in "1" "2" "3"
do
    case $opt in
        "1")
            sudo certbot -d $DOMAIN_URL --manual --preferred-challenges dns certonly
            break;;
        "2")
            sudo certbot certonly --standalone -d $DOMAIN_URL
            break;;		
        "3")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

notice "If any issues, recommend looking at docs for certbot: https://pterodactyl.io/tutorials/creating_ssl_certificates.html#auto-renewal"

notice "Clearing the variables from memory..."
unset DOMAIN_URL
success "Unsetting for security reasons.."
success "Done & Cleared!"

sudo systemctl start nginx

read -p "Enter the domain url (Example: nekohosting.gg): " DOMAIN_NAME

AVAILABLE_CONFIG="/etc/nginx/sites-available/wemx.conf"
ENABLED_CONFIG="/etc/nginx/sites-enabled/wemx.conf"

CONFIG_CONTENT="server {
    listen 80;
    server_name $DOMAIN_NAME;
    server_tokens off;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;

    root /var/www/wemx/public;
    index index.php;

    access_log /var/log/nginx/wemx.app-access.log;
    error_log  /var/log/nginx/wemx.app-error.log error;

    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers \"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384\";
    ssl_prefer_server_ciphers on;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection \"1; mode=block\";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy \"frame-ancestors 'self'\";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE \"upload_max_filesize = 100M \n post_max_size=100M\";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY \"\";
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
}"

echo "$CONFIG_CONTENT" > "$AVAILABLE_CONFIG"

sudo ln -s /etc/nginx/sites-available/wemx.conf /etc/nginx/sites-enabled/wemx.conf
sudo nginx -t
sudo systemctl restart nginx

success "Installation of WEMX & WEBSERVER is now Completed and should be running!"

echo "============================================================================"
echo "This was the entire installer!"
echo "Thank You for using the WemxPROAuto Installer!"
echo "Made by nwya#0 or VanillaChan#6571"
echo "============================================================================"
success "Exited WemxPRO-Installer-1.0.2"
