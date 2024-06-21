<p align="center">
<img alt="Wemx"
    src="https://cdn.discordapp.com/icons/760945720470667294/1f6cf16d3e468242cacc1b539e6b4561.webp?size=256">
</p>

<h1 align="center">WemxProAuto - Your Favorite Toolbox! </h1>

<p align="center">
 <b>
      The WPA (WemxProAuto) is a toolbox full of scripts to help you newbie or lazy linux users to update or fully install wemx!
    </b>
    <b>
      | Script was made by yours truely!
    <p align="center"><h2> Please Note This is a THIRD PARTY SCRIPT(s)! Wemx or Wemx Devs did not make these scripts!. </h2></p>
  </b>
</p>

<p align="center">
    <a href="https://discord.gg/vertisan-760945720470667294">
        <img alt="Discord" src="https://img.shields.io/discord/760945720470667294?color=7289DA&label=Discord&logo=discord&logoColor=7289DA">
    </a>
</p>

## Table of Contents 

*   [Introduction](#introduction)
*   [Auto Installation Script](#Auto-Installation)
*   [Auto Update Script](#Auto-Updater])
*   [WPA ToolBox Script](#WPA-Toolbox) {The One You will only need}
*   [Third Party + Extra's Installers](#Extra)
*   [Old Installers](#Old-Legacy-Installers)

## Introduction
<p>2.0.0 INFO: https://github.com/VanillaChan6571/WemxProAuto/wiki/2.0.0-Update-Experimental</p>

<p>This github uses https://wemx.net documentation on installing/updating.</p>
<p>If you wish to see the full documentaion for WEMX, Web: https://docs.wemx.net/en/home</p>
<p>If you need any support for WEMX Related issues, discord server: https://discord.com/invite/vertisan-760945720470667294</p>
<p>NOTICE: This Script Supports Ubuntu 22.04.x ONLY</p>

## Auto Installation

Auto Installer will install/add the following:
 - ppa:ondrej/php repository
 - software-properties-common
 - curl
 - apt-transport-https
 - ca-certificates
 - gnupg
 - Redis
 - Auto Upgrade & Update
 - PHP 8.1 w/ "{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server"
 - Composer + Laravel
 - WEMX or WEMX PRO
 - Certbot Configure w/ DNS Challenege or HTTP Challenege.
 - Configures Database Automatically w/ User Input.
 - Configures Webserver for WEMX w/ User Input.
 - More Info on https://docs.wemx.net/en/installation

## Auto Updater

Auto Update will update the following:
 - WEMX or WEMX PRO
 - Composer Update/Upgrades
 - migrate --seed --force
 - chown -R www-data:www-data /var/www/wemx/*
 - More Info on https://docs.wemx.net/en/updating

## WPA Toolbox
This Toolbox does all First Time Installing and Wemx Updating + more at https://github.com/VanillaChan6571/WemxProAuto/wiki/2.0.0-Update-Experimental
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 2.1.0 | 2.1.1 | **[Live Version - 2.1.1A](https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WPA-ToolBox-live.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WPA-ToolBox-live.sh) |
| 2.1.0 | 2.1.1A | **[2.1.1A](https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-WPA-Toolbox/WPA-ToolBox-2.1.1A.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-WPA-Toolbox/WPA-ToolBox-2.1.1A.sh) |
| 2.1.0 | 2.1.1 | **[2.1.1](https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-WPA-Toolbox/WPA-ToolBox-2.1.1.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-WPA-Toolbox/WPA-ToolBox-2.1.1.sh) |
| 2.0.1 | 2.0.0 | **[2.0.0](https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Installer/WemxPRO-Installer-2.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Installer/WemxPRO-Installer-2.0.sh) |

## Extra
Thirdparties / Extra Installers.
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 1.0.x-1.5.x | 1.0.0 | **[Live Version - 1.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/WemxPRO-SSO-Installer-live.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WemxPRO-SSO-Installer-live.sh) |
| 1.0.x-1.5.x | 1.0 | **[1.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-3rdParties/WemxPRO-SSO-Installer-1.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-3rdParties/WemxPRO-SSO-Installer-1.0.sh) |


## Old Legacy Installers
Some Old First Time Installer History
All Download Verions for Installer (Legacy)
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 1.7.0 | 1.0.2 | **[1.0.2](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Installer/WemxPRO-Installer-1.0.2.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Installer/WemxPRO-Installer-1.0.2.sh) |
| 1.5.0-1.6.4 | 1.0.1 | **[1.0.1](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Installer/WemxPRO-Installer-1.0.1.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Installer/WemxPRO-Installer-1.0.1.sh) |
| 1.4.0 | 1.0 | **[1.0.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Installer/WemxPRO-Installer-1.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Installer/WemxPRO-Installer-1.0.sh) |

Old Updater History
All Download Verions for Updater - Legacy
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 1.9.x | 1.0.3 | **[Live Version - 1.0.3](https://github.com/VanillaChan6571/WemxProAuto/blob/main/WemxPRO-Updater-live.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WemxPRO-Updater-live.sh) |
| 1.9.x | 1.0.3 | **[1.0.3](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Updater/WemxPRO-Updater-1.0.3.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Updater/WemxPRO-Updater-1.0.3.sh) |
| 1.7.0-1.8.x | 1.0.2 | **[1.0.2](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Updater/WemxPRO-Updater-1.0.2.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Updater/WemxPRO-Updater-1.0.2.sh) |
| 1.5.0-1.6.4 | 1.0.1 | **[1.0.1](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Updater/WemxPRO-Updater-1.0.1.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Updater/WemxPRO-Updater-1.0.1.sh) |
| 1.4.0 | 1.0 | **[1.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/History-Updater/WemxPRO-Updater-1.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/History-Updater/WemxPRO-Updater-1.0.sh) |

