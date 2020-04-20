#!/bin/bash
# Script to download individual .nc files from the ORNL
# Daymet server at: http://daymet.ornl.gov

echo ##################################################
echo ### Domoticz Diagnostic Support Package (DDSP) ###
echo ### version: 0.1                               ###
echo ##################################################
echo .
echo Creating temporary working directory...

if [ -d "/DDSP" ] 
then
    echo "DDSP directory already exists, clean up and starting over..."
	rm -rf /DDSP
	mkdir DDSP
else
    mkdir DDSP
fi
cd DDSP

echo Finding Domoticz location...
echo Gathering system information...
echo Gathering relevant system log files...
echo Gathering Domoticz information...
echo Gathering Domoticz log files...
echo Assembling and packing the DDSP output file...
echo Cleaning up
echo DDSP output file ready!
echo Please download the DDSP file from your Domoticz installation or copy this to your system...
echo You can download the file from your Domoticz webserver or from the DDSP directory 
read -p "Press any key to continue when you have retrieved the DDSP file, so we can clean everything up again..."


mkdir DDSP
cd DDSP

cp /var/log/messages .
cp /var/log/cron.log .
cp /var/log/kern.log .

find /home -name "domoticz" -print


