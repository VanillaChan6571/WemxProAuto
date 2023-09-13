clear
sleep 2s
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
echo "WemxPRO | Wemx x Pterodactyl SSO 1.0"
echo
echo "Copyright (C) 2021 - $(date +%Y), NekoHosting"
echo "https://github.com/VanillaChan6571/WemxProAuto"
echo
echo "This Script will need to modify the Pterodactyl files if needed."
echo "============================================================================"

#Checks to continue#

while true; do

read -p "Do you want to proceed with the script? [Script: WemxPRO-SSO-Installer-1.0] (y/N) " yn

case $yn in
	[yY] ) echo Continuing with the updater;
		break;;
	[nN] ) echo Exiting...;
		exit;;
	* ) echo Invalid Response;;
esac

done

if [ ! -d "/var/www/pterodactyl" ]; then
    error "Directory /var/www/pterodactyl does not exist. Please install pterodactyl before using wemx in general!"
	notice "IF you named "/var/www/pterodactyl" something else or located somewhere else, please modify the script."
    exit 1
elif [ -z "$(ls -A /var/www/pterodactyl)" ]; then
    error "Directory /var/www/pterodactyl is empty or null. Please install pterodactyl before using wemx in general!"
	notice "IF you named "/var/www/pterodactyl" something else or located somewhere else, please modify the script."
    exit 1
fi

cd /var/www/pterodactyl


cd /var/www/pterodactyl

COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/sso-pterodactyl

sudo php artisan vendor:publish --tag=sso-wemx

echo "Choose a command to run:"
echo "============================================================================"
echo "1. Generate a new SSO Secret Key"
echo "2. Skip Generating a new SSO Secret Key"
echo " "
echo "Please note that if you do re-run the Secret Key, it will not brick/lock anything up."
echo "============================================================================"
select opt in "1" "2"
do
    case $opt in
        "1")
            sudo php artisan wemx:generate
			notice "Head over to your Pterodactyl Configuration in Wemx and located in the Admin area of your application. Paste in your SSO key and save it."
			notice "The Script will continue in 20 seconds. Do not ^C at this point since you will be missing some commands."
			sleep 20s
            break;;		
        "2")
            break;;
        *) echo "Invalid option $REPLY";;
    esac
done

sudo php artisan cache:clear && php artisan config:clear

sudo chmod -R 755 storage/* bootstrap/cache/

sudo chown -R www-data:www-data /var/www/pterodactyl/*

success "Script Complete"
echo "============================================================================"
echo "This was the entire SSO Installer!"
echo "Thank You for using the WemxPROAuto SSO!"
echo "Made by nwya#0 or VanillaChan#6571"
echo "============================================================================"
success "Exited WemxPRO-SSO-1.0.0"
# This update was simple, but sometimes the docs do get updated, So this must be updated if the doc adds or removes stuff.
