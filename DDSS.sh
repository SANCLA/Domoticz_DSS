#!/bin/bash
# Script to download individual .nc files from the ORNL
# Daymet server at: http://daymet.ornl.gov
# Settings variables
DDSPDEBUG=1

echo "##################################################"
echo "### Domoticz Diagnostic Support Package (DDSP) ###"
echo "### version: 0.0010                            ###"
echo "##################################################"
echo 
echo ">>> Check if running as root..."
if [[ $EUID -ne 0 ]]; then
   echo "!!! This script must be run as root, please execute this with the sudo command !!!" 
   exit 1
fi




echo ">>> Starting Diagnostic Package..."




echo ">>> Install and configuring prequisites"
#apt install lshw sqlite3 tftp zip -y
apt install lshw tftp zip -y
#HISTFILE=~/.bash_history
#set -o history



echo ">>> Creating temporary working directory..."
if [ -d "./DDSP" ]; 
then
    echo "...DEBUG: DDSP directory already exists, cleaning up"
	echo "... DDSP directory already exists, clean up and starting over..."
	sudo rm -rf DDSP
	mkdir DDSP
else
    echo "...DEBUG: DDSP directory does not exist yet, creating it"
    mkdir DDSP
fi

if [ -d "DDSP-dianostic-package.zip" ]; 
then
    echo ">>> DDSP-dianostic-package.zip already exists, cleaning up..."
	sudo rm DDSP-dianostic-package.zip
else
    echo ">>> No previous diagnostic packages found, creating a new one..."
fi

cd DDSP




echo ">>> Finding Domoticz location..."

if [ -d "/home/pi/domoticz" ]; 
then
	echo "...DEBUG: Domoticz dir found in default directory /home/pi/domoticz"
	DOMODIR="/home/pi/domoticz"
else
#	echo "...Domoticz not found in default directory, trying to find it!"
#	find /home -type d -name "domoticz" -print
#	DOMODIR=[find /home -type d -name "domoticz"]
#	echo "...DOMODIR VARIABLE:"
#	echo DOMODIR
#	FoundDirs=0
#	find /home -type d -name "domoticz" 2>/dev/null | while read line; do
#		echo "Found the following Domoticz directory: '$line'"
#		echo "Found the following Domoticz directory: '$line'"
#		echo "Found the following Domoticz directory: '$line'"
#		echo "Found the following Domoticz directory: '$line'"
#		echo "Found the following Domoticz directory: '$line'"
#		FoundDirs=FoundDirs+1
#		domodir=$line
#		echo $domodir
#	done <"$DATAFILE"
#	
#	if [ $FoundDirs \> 1 ];
#	then
#		echo "Found more then one Domoticz directory..."
		echo "Please specify the correct Domoticz directory and press enter to continue."
		echo "For example /home/pi/domoticz"
		read DOMODIR
#	fi
fi


echo ">>> Gathering system information..."

echo -e "-------------------------------System Information----------------------------"
echo ""
echo -e "Hostname (FQDN):\t\t"`hostname`
echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "Kernel:\t\t\t"`uname -r`
echo -e "Kernel Version:\t\t"`uname -v`
echo -e "Architecture:\t\t"`arch`
echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
echo -e "Full OS:\t\t"`uname -a`
echo ""

echo -e "-------------------------------STATUS DOMOTICZ-------------------------------"
echo -e "Domoticz service status:"
/etc/init.d/domoticz.sh status
echo ""

echo -e "-------------------------------STATUS DOMOTICZ-------------------------------"
echo "Domoticz folder and rights:"
sudo ls -al $DOMODIR
echo ""

echo "Domoticz plugin folder and rights:"
sudo ls -al $DOMODIR\plugins

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

#echo -e "-------------------------------LAST APT UPDATE-------------------------------"
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt update'
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get update'
#echo ""
#
#echo -e "-------------------------------LAST APT UPGRADE------------------------------"
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt upgrade'
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get upgrade'
#echo ""
#
#echo -e "-------------------------------LAST APT INSTALL------------------------------"
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt install'
#HISTTIMEFORMAT="%d/%m/%y %T " history | grep '[a]pt-get install'
#echo ""

echo -e "-------------------------------------LSHW------------------------------------"
sudo lshw -short
echo ""

echo -e "------------------------------------LSCPU------------------------------------"
sudo lscpu
echo ""

echo -e "------------------------------------LSUSB------------------------------------"
sudo lsusb
echo ""

echo -e "------------------------------APT UPDATE CHECK-------------------------------"
apt update --assume-no
echo ""

echo -e "------------------------------APT UPGRADE CHECK------------------------------"
apt upgrade --assume-no
echo ""


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

if [ "/var/log/syslog" ]; 
	then
		echo "...DEBUG: /var/log/syslog found, including it"
		cp /var/log/syslog .
	else
		echo "...DEBUG: /var/log/syslog NOT found, skipping..." 	
fi

echo ">>> Gathering Domoticz information..."

cp /etc/init.d/domoticz.sh etc-initd-domoticz.sh


echo ">>> Running Domoticz with debug log enable for 1 minute"

sudo /etc/init.d/domoticz.sh stop
cd $DOMODIR
sudo ./domoticz -loglevel normal,status,error,debug -debug -verbose -log /home/pi/DDSP/domoticz.log & sleep 60 ; kill $!
sleep 10
sudo /etc/init.d/domoticz.sh start

echo ">>> Assembling and packing the DDSP output file..."

cd $home
sudo zip -r DDSP-diagnostic-package.zip $home/DDSP


echo ">>> Cleaning up"
sudo rm -rf DDSP
sudo cp $home/DDSP-diagnostic-package.zip $DOMODIR/www/DDSP.zip
echo ">>> DDSP output file ready!"
echo ">>> Please download the DDSP file from your Domoticz installation or copy this to your system..."
echo ">>> You can download the file from your Domoticz webserver or from the DDSP directory "
echo ">>> To download the output package, open the following link in your browser:"
echo -e ">>> http://"`hostname -I`":8080/DDSP.zip"
read -p ">>> Press any key to continue when you have retrieved the DDSP file, so we can clean everything up again..."
read t1

echo "...DEBUG: Removing the DDSP directory"
cd

echo ">>> All done!"