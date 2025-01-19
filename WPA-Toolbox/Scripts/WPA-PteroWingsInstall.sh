# todo, Wings Install

To run Wings, you will need a Linux system capable of running Docker containers. Most VPS and almost all dedicated servers should be capable of running Docker, but there are edge cases.

When your provider uses Virtuozzo, OpenVZ (or OVZ), or LXC virtualization, you will most likely be unable to run Wings. Some providers have made the necessary changes for nested virtualization to support Docker. Ask your provider's support team to make sure. KVM is guaranteed to work.

The easiest way to check is to type systemd-detect-virt. If the result doesn't contain OpenVZ orLXC, it should be fine. The result of none will appear when running dedicated hardware without any virtualization.

Should that not work for some reason, or you're still unsure, you can also run the command below.

sudo dmidecode -s system-manufacturer

# Installing Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable bash

sudo systemctl enable --now docker

Enabling Swap

On most systems, Docker will be unable to setup swap space by default. You can confirm this by running docker info and looking for the output of WARNING: No swap limit support near the bottom.

Enabling swap is entirely optional, but we recommended doing it if you will be hosting for others and to prevent OOM errors.

To enable swap, open /etc/default/grub as a root user and find the line starting with GRUB_CMDLINE_LINUX_DEFAULT. Make sure the line includes swapaccount=1 somewhere inside the double-quotes.

After that, run sudo update-grub followed by sudo reboot to restart the server and have swap enabled. Below is an example of what the line should look like, do not copy this line verbatim. It often has additional OS-specific parameters.

GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"

GRUB Configuration

Some Linux distros may ignore GRUB_CMDLINE_LINUX_DEFAULT. Therefore you might have to use GRUB_CMDLINE_LINUX instead should the default one not work for you.

sudo mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
sudo chmod u+x /usr/local/bin/wings

OVH/SYS Servers

If you are using a server provided by OVH or SoYouStart please be aware that your main drive space is probably allocated to /home, and not / by default. Please consider using /home/daemon-data for server data. This can be easily set when creating the node.