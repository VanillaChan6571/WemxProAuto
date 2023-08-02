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
echo "WemxPRO | Wemx Pro Update Script 1.0.1"
echo
echo "Copyright (C) 2021 - $(date +%Y), NekoHosting"
echo "https://github.com/VanillaChan6571/WemxProAuto"
echo
echo "This install script will replace any files it needs to."
echo "============================================================================"
echo "Patch Notes for 1.0.1"
echo "+ Added better way for WEMX Key to be used."
echo "+ Forked the ending script from installer to updater."
echo " "
echo "If you wish to download the older versions, you can on the github"
echo "============================================================================"

#Checks to continue#

while true; do

read -p "Do you want to proceed with the script? [Script: WemxPRO-Updater-1.0] (y/N) " yn

case $yn in
	[yY] ) echo Continuing with the updater;
		break;;
	[nN] ) echo Exiting...;
		exit;;
	* ) echo Invalid Response;;
esac

done

cd /var/www/wemx

notice "Wemx Installer will be ran in this setup... We will need the key for it to work."

read -p "Enter the License Key for WEMX: " WEMX_KEY

notice "if you wish to not always enter your license key, edit this script to find out more!"

COMPOSER_ALLOW_SUPERUSER=1 composer require wemx/installer dev-wemxpro

php artisan wemx:install $WEMX_KEY --eula=yes

#Hello! If you are reading this, you can technically use the following:
#php artisan wemx:install license-key-here --eula=yes
#This will make it more automated and really let it do everything.

chmod -R 755 storage/* bootstrap/cache

COMPOSER_ALLOW_SUPERUSER=1 composer update
COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader

php artisan module:enable

php artisan view:clear && php artisan config:clear

php artisan migrate --seed --force

chown -R www-data:www-data /var/www/wemx/*

notice "Clearing the WEMX KEY variable from memory..."
unset WEMX_KEY
success "Unsetting for security reasons.."
success "Done & Cleared!"

success "Script Complete"
echo "============================================================================"
echo "This was the entire updater!"
echo "Thank You for using the WemxPROAuto Updater!"
echo "Made by nwya#0 or VanillaChan#6571"
echo "============================================================================"
success "Exited WemxPRO-Updater-1.0.1"
# This update was simple, but sometimes the docs do get updated, So this must be updated if the doc adds or removes stuff.