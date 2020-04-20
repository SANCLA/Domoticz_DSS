#!/bin/bash
# Script to download individual .nc files from the ORNL
# Daymet server at: http://daymet.ornl.gov
# Settings variables
DDSPDEBUG=1

echo "##################################################"
echo "### Domoticz Diagnostic Support Package (DDSP) ###"
echo "### version: 0.0004                            ###"
echo "##################################################"
echo 
echo ">>> Check if running as root..."
if [[ $EUID -ne 0 ]]; then
   echo "!!! This script must be run as root, please execute this with the sudo command !!!" 
   exit 1
fi

echo ">>> Starting Diagnostic Package..."

echo ">>> Install prequisites"
apt install lshw -y


echo ">>> Creating temporary working directory..."


if [ -d "DDSP" ]; 
then
    echo "...DEBUG: DDSP directory already exists, cleaning up"
	echo "... DDSP directory already exists, clean up and starting over..."
	rm -rf DDSP
	mkdir DDSP
else
    echo "...DEBUG: DDSP directory does not exist yet, creating it"
    mkdir DDSP
fi

cd DDSP






echo ">>> Finding Domoticz location..."

if [ -d "/home/pi2/domoticz" ]; 
then
	echo "...DEBUG: Domoticz dir found in default directory /home/pi2/domoticz"
	DOMODIR="/home/pi/domoticz"
else
	echo "...Domoticz not found in default directory, trying to find it!"
	find /home -type d -name "domoticz" -print
	DOMODIR=[find /home -type d -name "domoticz"]
	echo "...DOMODIR VARIABLE:"
	echo DOMODIR
fi






echo ">>> Gathering system information..."

echo -e "-------------------------------System Information----------------------------"
echo -e "Hostname (FQDN):\t\t"`hostname`
echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "Kernel:\t\t\t"`uname -r`
echo -e "Kernel Version:\t\t"`uname -v`
echo -e "Architecture:\t\t"`arch`
echo -e "Machine Hardware Architecture:\t\t"`uname --m`
echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
echo -e "Full uname:\t\t"`uname -a`
echo ""

echo -e "-----------------------------------NETWORK-----------------------------------"

echo -e "System Main IP:\t\t"`hostname -I`
echo -e "DNS Servers:\t\t"`${dnsips}`
echo ""
netstat -nr
echo ""
netstat -i
echo ""

echo -e "-------------------------------CPU/Memory Usage------------------------------"
echo -e "Free and used memory: "
free -m
echo ""
echo -e "Virtual memory statistics: "
vmstat
echo ""
echo -e "Top 5 memory eating proces: "
ps auxf | sort -nr -k 4 | head -5	
echo ""

echo -e "-------------------------------LAST APT UPDATE-------------------------------"
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt update'
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get update'
echo ""

echo -e "-------------------------------LAST APT UPGRADE------------------------------"
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt upgrade'
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get upgrade'
echo ""

echo -e "-------------------------------LAST APT INSTALL------------------------------"
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt install'
HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get install'
echo ""

echo -e "-------------------------------------LSHW------------------------------------"
sudo lshw -short
echo ""

echo -e "------------------------------------LSCPU------------------------------------"
sudo lscpu
echo ""

echo -e "------------------------------------LSUSB------------------------------------"
sudo lsusb
echo ""

if (( $(cat /etc/*-release | grep -w "Oracle|Red Hat|CentOS|Fedora" | wc -l) > 0 ))
then
echo -e "-------------------------------Package Updates-------------------------------"
yum updateinfo summary | grep 'Security|Bugfix|Enhancement'
echo -e "-----------------------------------------------------------------------------"
else
echo -e "-------------------------------Package Updates-------------------------------"
cat /var/lib/update-notifier/updates-available
echo -e "-----------------------------------------------------------------------------"
fi





echo ">>> Gathering installed packages"
apt list >> package_list.txt






echo ">>> Gathering relevant system log files..."

if [ "/var/log/messages" ]; 
	then
		echo "...DEBUG: /var/log/messages found, including it"
		cp /var/log/messages .
	else
		echo "...DEBUG: /var/log/messages NOT found, skipping..."
fi

if [ "/var/log/kern.log" ]; 
	then
		echo "...DEBUG: /var/log/kern.log found, including it"
		cp /var/log/kern.log .
	else
		echo "...DEBUG: /var/log/kern.log NOT found, skipping..."		
fi

if [ "/var/log/cron.log" ]; 
	then
		echo "...DEBUG: /var/log/cron.log found, including it"
		cp /var/log/cron.log .
	else
		echo "...DEBUG: /var/log/cron.log NOT found, skipping..." 	
fi

echo ">>> Gathering Domoticz information..."
echo ">>> Gathering Domoticz log files..."
echo ">>> Assembling and packing the DDSP output file..."
echo ">>> Cleaning up"
echo ">>> DDSP output file ready!"
echo ">>> Please download the DDSP file from your Domoticz installation or copy this to your system..."
echo ">>> You can download the file from your Domoticz webserver or from the DDSP directory "
read -p ">>> Press any key to continue when you have retrieved the DDSP file, so we can clean everything up again..."

echo "...DEBUG: Removing the DDSP directory"
rm -rf DDSP
rm -rf /DDSP
echo ">>> All done!"