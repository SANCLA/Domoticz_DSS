#!/bin/bash
# Script to download individual .nc files from the ORNL
# Daymet server at: http://daymet.ornl.gov
# Settings variables
DDSPDEBUG=1

echo "##################################################"
echo "### Domoticz Diagnostic Support Package (DDSP) ###"
echo "### version: 0.1                               ###"
echo "##################################################"
echo 
echo ">>> Starting Diagnostic Package..."
echo ">>> Creating temporary working directory..."


if [ -d "/DDSP" ] 
then
    if [ "DDSPDEBUG" = "1" ]; then echo "...DEBUG: DDSP directory already exists, cleaning up" fi
	echo "... DDSP directory already exists, clean up and starting over..."
	rm -rf /DDSP
	mkdir DDSP
else
    if [ "DDSPDEBUG" = "1" ]; then echo "...DEBUG: DDSP directory does not exist yet, creating it" fi
    mkdir DDSP
fi

cd DDSP

echo ">>> Finding Domoticz location..."

if [ -d "/home/pi/domoticz" ] 
then
	if [ "DDSPDEBUG" = "1" ]; then echo "...DEBUG: Domoticz dir found in default directory /home/pi/domoticz" fi
	DOMODIR="/home/pi/domoticz"
else
	echo "...Domoticz not found in default directory, trying to find it!"
	find /home -type d -name "domoticz" -print
	DOMODIR=find /home -type d -name "domoticz"
fi

echo Gathering system information...
echo Gathering relevant system log files...

if [ "/var/log/messages" ] 
	then
		cp /var/log/messages .
fi

if [ "/var/log/kern.log" ] 
	then
		cp /var/log/kern.log .
fi

if [ "/var/log/cron.log" ] 
	then
		cp /var/log/cron.log .
fi

echo Gathering Domoticz information...
echo Gathering Domoticz log files...
echo Assembling and packing the DDSP output file...
echo Cleaning up
echo DDSP output file ready!
echo Please download the DDSP file from your Domoticz installation or copy this to your system...
echo You can download the file from your Domoticz webserver or from the DDSP directory 
read -p "Press any key to continue when you have retrieved the DDSP file, so we can clean everything up again..."

rm -rf /DDSP
echo All done!






