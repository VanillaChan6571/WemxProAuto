<p align="center">
<img alt="MultiEgg Plugin + Addon Reinstaller"
    src="https://cdn.discordapp.com/icons/760945720470667294/1f6cf16d3e468242cacc1b539e6b4561.webp?size=256">
</p>

<h1 align="center">WemxProAuto - Your Favorite Toolbox! </h1>

<p align="center">
 <b>
      The WPA (WemxProAuto) is a toolbox full of scripts to help you newbie or lazy linux users to update or fully install wemx!
    </b>
    <b>
      | Script was made by yours truely!
  </b>
</p>

<p align="center">
    <a href="https://discord.gg/vertisan">
        <img alt="Discord" src="https://img.shields.io/discord/760945720470667294?color=7289DA&label=Discord&logo=discord&logoColor=7289DA">
    </a>
</p>

## Table of Contents 

*   [Introduction](#introduction)
*   [Auto Installation Script](#Auto-Installation)
*   [Auto Update Script](#Auto-Uodater])
*   [Download History Installer](#Download-History)
*   [Download History Updater](#Update-History)

## Introduction
<p>This github uses https://wemx.pro documentation on installing/updating.</p>
<p>If you wish to see the full documentaion for WEMX, Web: https://docs.wemx.net/en/home</p>
<p>If you need any support for WEMX Related issues, discord server: https://discord.gg/vertisan</p>
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

## Download History
All Download Verions for Installer
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 1.4.0 | 1.0 | **[Current Version - 1.0.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/WemxPRO-Installer-1.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WemxPRO-Installer-1.0.sh) |

## Update History
All Download Verions for Updater
| Wemx Version | Script Version | Download | Unix Bash Code |
| --- | --- | -------------------- | -------------------- |
| 1.4.0 | 1.0 | **[Current Version - 1.0](https://github.com/VanillaChan6571/WemxProAuto/blob/main/WemxPRO-Updater-1.0.sh)** | bash <(curl -s https://raw.githubusercontent.com/VanillaChan6571/WemxProAuto/main/WemxPRO-Updater-1.0.sh) |
