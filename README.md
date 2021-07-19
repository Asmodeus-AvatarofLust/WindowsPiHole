# Pi-Hole on Windows 10 Machine

## Quick Notice
This script is a rewritten code from @DesktopEcho 's script. I take no credits neither for Pi-Hole as a software nor for the script, as I am not original creator of neither. The reason behind me rewritting this script @DesktopEcho wrote is that his script is quite messy and inefficient. 

## Script update 22-05-2021
DesktopEcho reworked this script and instead of using Ubuntu 20.04, it uses Debian Buster in order to reduce memory footprint.
It also now has integrated cloudflared DNS over HTTPS and enabled DOH in default configuration.

This script STILL fetches CloudFlared DNS from [original repository](https://github.com/DesktopECHO/Pi-Hole-for-WSL1).

### Credits

[Pi-Hole](https://pi-hole.net/)

[Pi-Hole Github](https://github.com/pi-hole/pi-hole)

[DesktopEcho](https://github.com/DesktopECHO)

[DesktopEcho's Script](https://github.com/DesktopECHO/Pi-Hole-for-WSL1)

## How does it work
### Script
This script works by utilizing the Windows Subsystem for Linux, so it is possible to run Pi-Hole on Windows machine just like any other Windows Application. It will perform an automatic installation of Pi-Hole on Windows 10 (Recommended to be up-to-date for both Windows version and build version) and/or Windows Server 2019 (Core and Standard), without any need of **Virtualization**, **Docker** or **Linux expertise**.

This approach uses fewer resources than the better-known hypervisor/container solution, and runs on older CPU's without VT support, or on a VPS without pass-through virtualization.

# Pi-Hole

## Requirements
Windows Version 10 **Highly Recommended**.

You can try Windows 11 as well, but I do not guarantee that it will work.

Requires August/September 2020 WSL Update; thus:

Supported versions of Windows: 

1809 - KB4571748 Update Required.

1909 - KB4566116 Update Required.

2004 - KB4571756 Update Required.

20H2 - Has it included.

21H1 - Has it included.

## Instructions
Copy ~~PiHWinv1.0.cmd~~ PiHole4Win10.bat to your desktop, right click on it and select "Run as Administrator".
- ~~Script **will not** run unless ran as Administrator. It needs to have Administrator priviledges in order for it to successfully setup.~~
- I have made few changes to this script, and one of them is that I have put a more efficient "administrator privileges checker" before script, so even if you ran it without Administrator Privileges.
- Same script has also been added when creating Uninstaller, so you can not accidentally start Uninstaller without privileges and making it fail everything, so you gotta restart and mess around etc etc...

## What will this Script do
Speed of how fast will Script finish downloading/configuring depends on your hardware and internet speed.
Script will:
* Enable WSL1.
* ~~Download [Ubuntu 20.04](https://aka.ms/wslubuntu2004) from Microsoft.~~
* Download [Debian 10](https://salsa.debian.org/debian/WSL/-/raw/master/x64/install.tar.gz) from [debian.org](debian.org).
* Download [LxRunOffline distro Manager](https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip).
* ~~Install Ubuntu 20.04.~~
* Install Debian 10.
* Perform gateway detection and create a /etc/pihole/setupVars.conf file for automated install.
* Run the [installer](https://github.com/pi-hole/pi-hole/#one-step-automated-install) from Pi-Hole.
* Patch Pi-hole installer to use netstat.exe instead of lsof, along with other fix-ups for WSL1 compatibility.
* Add exceptions to Windows Firewall for DNS and the Pi-hole admin page.
* Includes a Scheduled Task to auto-start on boot, before logon.
* **If it does not start automatically, it means that this script failed to create Scheduled Task properly, which is common. Configure it manually in order for it to work**. If you do not know how to do so, you can find short guide below.

#### Task Scheduler
* Open Windows Task Scheduler (taskschd.msc) and right-click the Pi-hole for Windows task, click edit.
* On the General tab, place a checkmark next to both Run whether user is logged on or not and Hidden.
* On the Conditions tab, un-check the option Start the task only if the computer is on AC power.

## Configuration

Pi-Hole configuration batch file can be found in C:\Program Files.
