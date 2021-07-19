@CHCP 65001 > nul

@Echo off & NET SESSION >nul 2>&1

SET version=1.1.0b

title Rewritten Pi-Hole Script 4 Windows 10 - %version%


::----------------------------------------------------------------------------------

:: This part of the script checks if the script has been run as an Administrator.
:: because it needs to have administrator privileges in order to run properly.
:: If it determines that it is not run as an Administrator, it will request
:: evelation via VBS script, and it will prompt you to press Yes to run it
:: as an Administrator in order for the script to continue. 

:: Checking for Admin Permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
:: If error flag set, we do not have admin.
:: If no admin, reqeust admin via VBS script
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
:: delete script after getting admin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
::----------------------------------------------------------------------------------

POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"

SET PORT=80

START /MIN /WAIT "Check for Open Port" "POWERSHELL" "-COMMAND" "Get-NetTCPConnection -LocalPort 80 > '%TEMP%\PortCheck.tmp'"

FOR /f %%i in ("%TEMP%\PortCheck.tmp") do set SIZE=%%~zi 

IF %SIZE% gtr 0 SET PORT=60080

:INPUTS

::----------------------------------------------------------------------------------

:: Prints out stuff that is below in the Command Prompt.
CLS
Echo ------------------------------ Rewritten Pi-Hole Script for Windows 10  ------------------------------
Echo ------------------------------       %date%, %time%, %version%          ------------------------------

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: Setting default location for Pi-Hole installation; also makes it possible for
:: you to customize it, so you can install it whenever you want to.
SET PRGP=%PROGRAMFILES%&SET /P "PRGP=Set location for 'Pi-hole' install folder or hit enter for default [%PROGRAMFILES%] -> "
SET PRGF=%PRGP%\Pi-hole

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: Checking if Pi-Hole is already installed, and notifies you that you must uninstall
:: it first if you want to continue with the script.
IF EXIST "%PRGF%" (ECHO. & ECHO Pi-hole folder already exists, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
WSL.EXE -d Pi-hole -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO Existing Pi-hole installation detected, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: Prints out stuff that is below in the Command Prompt.
Echo Pi-hole will be installed in "%PRGF%" and Web Admin will listen on port %PORT%.
Echo Press any button to continue with the installation...
pause >nul

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: Checks if Debian installation is present in %temp% directory.
:: Previous version of this script was using Ubuntu 20.04, but the original guy
:: that made this script stated that it was switched to reduce footprint.
:: https://github.com/DesktopECHO/Pi-Hole-for-WSL1
IF NOT EXIST %TEMP%\debian.tar.gz POWERSHELL.EXE -Command "Start-BitsTransfer -source https://salsa.debian.org/debian/WSL/-/raw/master/x64/install.tar.gz?inline=false -destination '%TEMP%\debian.tar.gz'"

::----------------------------------------------------------------------------------

%PRGF:~0,1%: & MKDIR "%PRGF%" & CD "%PRGF%" & MKDIR "logs" 
FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v"
ICACLS "%PRGF%" /grant "%WAI%:(CI)(OI)F" > NUL

::----------------------------------------------------------------------------------

:: This part of the script writes "Pi-Hole Uninstall.cmd" file.
:: This part is changed from what it was in the original script, so you can not
:: accidentally run it without administrator privileges, and possibly screwing
:: something. 


Echo :: This part of the script checks if the script has been run as an Administrator. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: because it needs to have administrator privileges in order to run properly. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: If it determines that it is not run as an Administrator, it will request >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: evelation via VBS script, and it will prompt you to press Yes to run it >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: as an Administrator in order for the script to continue.  >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: Checking for Admin Permissions >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: If error flag set, we do not have admin. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: If no admin, reqeust admin via VBS script >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo if '%errorlevel%' NEQ '0' ( >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     Echo echo Requesting administrative privileges... >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     goto UACPrompt >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo ) else ( goto gotAdmin ) >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :UACPrompt >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     "%temp%\getadmin.vbs" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     exit /B >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :gotAdmin >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo :: delete script after getting admin >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo     if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" ) >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo    pushd "%CD%" >> "%PRGF%\Pi-hole Uninstall.cmd" 
Echo     CD /D "%~dp0" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo ::---------------------------------------------------------------------------------- >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo.  >> "%PRGF%\Pi-hole Uninstall.cmd" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Echo Administrator privileges gained. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Echo Press any button to continue with Pi-Hole uninstallation... >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Pause >nul  >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo copy /y "%PRGF%\LxRunOffline.exe" "%TEMP%" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo schtasks /Delete /TN:"Pi-Hole for Windows" /F >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Echo Uninstalling Pi-Hole... >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo NetSH AdvFirewall Firewall del rule name="Pi-Hole FTL" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo NetSH AdvFirewall Firewall del rule name="Pi-Hole Web Admin" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (TCP)" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (UDP)" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo %PRGF:~0,1%: >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo CD "%PRGF%\.." >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo WSLCONFIG /T Pi-hole >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo "%TEMP%\LxRunOffline.exe" ur -n Pi-hole >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo RD /S /Q "%PRGF%" >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Echo Pi-Hole Uninstalled. >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Echo Press any button to exit... >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo Pause >nul >> "%PRGF%\Pi-hole Uninstall.cmd"
Echo exit >> "%PRGF%\Pi-hole Uninstall.cmd"

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: Prints out stuff that is below in the Command Prompt.
Echo.
Echo This will take a few minutes to complete, depending on your internet speed and your configuration...

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: This part installs both LxRunOffline and Debian, so you can use your Pi-Hole.
ECHO|SET /p="Installing LXrunOffline.exe and Debian..."
POWERSHELL.EXE -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; wget https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip -UseBasicParsing -OutFile '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' ; Expand-Archive -Path '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' -DestinationPath '%PRGF%'"

START /WAIT /MIN "Installing Debian..." "LxRunOffline.exe" "i" "-n" "Pi-hole" "-f" "%TEMP%\debian.tar.gz" "-d" "."
ECHO|SET /p="-> Compacting install..." 
SET GO="%PRGF%\LxRunOffline.exe" r -n Pi-hole -c 
%GO% "apt-get -y purge dmsetup libapparmor1 libargon2-1 libdevmapper1.02.1 libestr0 libfastjson4 libidn11 libjson-c3 liblognorm5 rsyslog systemd systemd-sysv vim-common vim-tiny xxd --autoremove --allow-remove-essential" > "%PRGF%\logs\Pi-hole Compact Stage.log"
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh /etc/init.d/udev"

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: This part will STILL use @DesktopEcho's Github as a repository to fetch
:: "cloudflared" from.
ECHO.-^> Install dependencies...
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; apt-get update ; apt-get -y install gpg wget curl ca-certificates libpcre2-8-0 libpsl5 openssl perl-modules-5.28 libgdbm6 libgdbm-compat4 libperl5.28 perl libcurl3-gnutls liberror-perl git lsof unattended-upgrades anacron cron logrotate inetutils-syslogd dns-root-data dnsutils gamin idn2 libgamin0 lighttpd netcat php-cgi php-common php-intl php-sqlite3 php-xml php7.3-cgi php7.3-cli php7.3-common php7.3-intl php7.3-json php7.3-opcache php7.3-readline php7.3-sqlite3 php7.3-xml sqlite3 unzip dhcpcd5 --no-install-recommends" > "%PRGF%\logs\Pi-hole Dependency Stage.log"
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; wget -q https://raw.githubusercontent.com/DesktopECHO/Pi-Hole-for-WSL1/master/cloudflared ; wget -q https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb ; dpkg -i ./cloudflared-stable-linux-amd64.deb ; chmod +x cloudflared ; mv cloudflared /etc/init.d ; update-rc.d cloudflared defaults; apt-get clean" > "%PRGF%\logs\CloudflareD.log"
%GO% "pw=$(gpg --quiet --gen-random --armor 1 512) ; useradd -m -p $pw -s /bin/bash cloudflared" > NUL
%GO% "mkdir /etc/pihole ; touch /etc/network/interfaces"
%GO% "IPC=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPC=$(ip -o addr show | grep $IPC) ; echo $IPC | sed 's/.*inet //g' | sed 's/\s.*$//'" > logs\IPC.tmp && set /p IPC=<logs\IPC.tmp
%GO% "IPF=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPF=$(ip -o addr show | grep $IPF) ; echo $IPF | sed 's/.*: //g'    | sed 's/\s.*$//'" > logs\IPF.tmp && set /p IPF=<logs\IPF.tmp
%GO% "echo PIHOLE_DNS_1=127.0.0.1#5053 >  /etc/pihole/setupVars.conf"
%GO% "echo IPV4_ADDRESS=%IPC%          >> /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_INTERFACE=%IPF%      >> /etc/pihole/setupVars.conf"
%GO% "echo BLOCKING_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo QUERY_LOGGING=true          >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_SERVER=true     >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_INTERFACE=true  >> /etc/pihole/setupVars.conf"
%GO% "echo LIGHTTPD_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo DNSMASQ_LISTENING=all       >> /etc/pihole/setupVars.conf"
%GO% "echo WEBPASSWORD=                >> /etc/pihole/setupVars.conf"
%GO% "echo interface %IPF%             >  /etc/dhcpcd.conf"
%GO% "echo static ip_address=%IPC%     >> /etc/dhcpcd.conf"
NetSH AdvFirewall Firewall add rule name="Pi-hole FTL"        dir=in action=allow program="%PRGF%\rootfs\usr\bin\pihole-ftl" enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole Web Admin"  dir=in action=allow program="%PRGF%\rootfs\usr\sbin\lighttpd"  enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (TCP)"  dir=in action=allow protocol=TCP localport=53 enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (UDP)"  dir=in action=allow protocol=UDP localport=53 enable=yes > NUL

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: This part of the script installs ACTUAL Pi-Hole. Everything before this part
:: was installing its' dependencies and generating stuff for it.
Echo.
Echo Installing Pi-Hole...
Echo.
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; curl -L https://install.Pi-hole.net | bash /dev/stdin --unattended"
:: DNS service indicator on web page and Removing DHCP server tab.
%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g'         /var/www/html/admin/settings.php"
%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g'                                        /var/www/html/admin/settings.php"
%GO% "sed -i 's#if ($pistatus === \"1\")#if ($pistatus === \"-1\")#g'         /var/www/html/admin/scripts/pi-hole/php/header.php"
%GO% "sed -i 's#elseif ($pistatus === \"-1\")#elseif ($pistatus === \"1\")#g' /var/www/html/admin/scripts/pi-hole/php/header.php"
:: Set Web Admin port to Installer Specifications
%GO% "sed -i 's/= 80/= %PORT%/g'                                              /etc/lighttpd/lighttpd.conf"
:: Debug log parsing on WSL1
%GO% "sed -i 's* -f 3* -f 4*g'                                                /opt/pihole/piholeDebug.sh"
%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g'                               /opt/pihole/piholeDebug.sh"
:: Configuring lsof alternative for WSL1
%GO% "sed -i 's#lsof -Pni:53#netstat.exe -ano | grep \":53 \"#g'              /usr/local/bin/pihole"
%GO% "sed -i 's#if grep -q \"pihole\"#if grep -q \"LISTENING\"#g'             /usr/local/bin/pihole"  
%GO% "sed -i 's#IPv4.*UDP#UDP    0.0.0.0:53#g'                                /usr/local/bin/pihole"
%GO% "sed -i 's#IPv4.*TCP#TCP    0.0.0.0:53#g'                                /usr/local/bin/pihole" 
%GO% "sed -i 's#IPv6.*UDP#UDP    \\[::\\]:53#g'                               /usr/local/bin/pihole" 
%GO% "sed -i 's#IPv6.*TCP#TCP    \\[::\\]:53#g'                               /usr/local/bin/pihole"
:: Removing unneeded service check
%GO% "sed -i 's#${CROSS} DNS service is NOT listening#Process Complete#g'     /usr/local/bin/pihole"
:: Get Pi-Hole Status
%GO% "PiHole status"          
%GO% "touch /var/run/syslog.pid ; chmod 600 /var/run/syslog.pid ; touch /etc/pihole/custom.list ; chown pihole:pihole /etc/pihole/custom.list ; chmod 644 /etc/pihole/custom.list ; touch /etc/pihole/local.list ; chown pihole:pihole /etc/pihole/local.list ; chmod 644 /etc/pihole/local.list ; pihole restartdns"
%GO% "echo ; echo ------------------------------------------------------------------------------- ; echo -n 'Pi-hole Web Admin, ' ; pihole -a -p"

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

:: This part of the script writes "Pi-Hole Launcher.cmd" and 
:: "Pi-Hole Configuration.cmd" files.

:: Pi-Hole Launcher File
Echo WSLCONFIG /T Pi-Hole >> "%PRGF%\Pi-hole Launcher.cmd"
Echo Echo [Pi-Hole Launcher] >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "apt-get -qq remove dhcpcd5 > /dev/null 2>&1 ; apt-get clean" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service start ; done ; sleep 3" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo Exit >> "%PRGF%\Pi-hole Launcher.cmd"

:: Pi-Hole Configuration File
Echo WSLCONFIG /T Pi-Hole >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "Echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; pihole -r" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#lsof -Pni:53#netstat.exe -ano | grep \":53 \"#g'          /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#if grep -q \"pihole\"#if grep -q \"LISTENING\"#g'         /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#IPv4.*UDP#UDP    0.0.0.0:53#g'                            /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#IPv4.*TCP#TCP    0.0.0.0:53#g'                            /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#IPv6.*UDP#UDP    \\[::\\]:53#g'                           /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#IPv6.*TCP#TCP    \\[::\\]:53#g'                           /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#${CROSS} DNS service is NOT listening#Process Complete#g' /usr/local/bin/pihole" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g' /var/www/html/admin/settings.php" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's*DHCP</a>*DHCP</a-->*g' /var/www/html/admin/settings.php" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's/= 80/= %PORT%/g'  /etc/lighttpd/lighttpd.conf" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's* -f 3* -f 4*g' /opt/pihole/piholeDebug.sh" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g' /opt/pihole/piholeDebug.sh" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#if ($pistatus === \"1\")#if ($pistatus === \"-1\")#g'         /var/www/html/admin/scripts/pi-hole/php/header.php" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "sed -i 's#elseif ($pistatus === \"-1\")#elseif ($pistatus === \"1\")#g' /var/www/html/admin/scripts/pi-hole/php/header.php" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo %GO% "PiHole status" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole Launcher.cmd" >> "%PRGF%\Pi-hole Launcher.cmd"
Echo START http://%COMPUTERNAME%:%PORT%/admin >> "%PRGF%\Pi-hole Launcher.cmd"
Echo -------------------------------------------------------------------------------
SET STTR="%PRGF%\Pi-hole Launcher.cmd"

::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

SCHTASKS /CREATE /RU "%USERNAME%" /RL HIGHEST /SC ONSTART /TN "Pi-hole for Windows" /TR '%STTR%' /F


::----------------------------------------------------------------------------------
::----------------------------------------------------------------------------------

START /WAIT /MIN "Pi-hole Launcher" "%PRGF%\Pi-hole Launcher.cmd"
ECHO. & ECHO Pi-hole for Windows installed in %PRGF%
(ECHO.Input Specifications: & ECHO. && ECHO. Location: %PRGF% && ECHO.Interface: %IPF% && ECHO.  Address: %IPC% && ECHO.     Port: %PORT% && ECHO.     Temp: %TEMP% && ECHO.) >  "%PRGF%\logs\Pi-hole Inputs.log"
DIR "%PRGF%" >> "%PRGF%\logs\Pi-hole Inputs.log"
CD .. & PAUSE
START http://%COMPUTERNAME%:%PORT%/admin
ECHO.
:ENDSCRIPT