#!/bin/bash

trap 'on_exit; exit' SIGINT # Redirect SIGINT signal (CTRL + C) to function on_exit() then exit program

## For colored messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

## If erazor is killed by Ctrl + C, kill all shred processus
function on_exit() {
	echo -e "\n${RED}Killing all shred...${NO_COLOR}"
	killall shred
	echo -e "${GREEN}OK !${NO_COLOR}"
}

## Use shred on given Disk ID (ex. : /dev/sdb)
function eraze_disk {
        echo "Erazing disk $1" >> log.txt
        echo "Erazing disk $1"
        shred -zvn 0 $1
	sleep 10
        echo "Finish for disk $1" >> log.txt
        echo -e "${GREEN}Finish for disk $1${NO_COLOR}"
}


## Install utilities
function install_dependencies {

        present=$(grep 'deb http://hwraid.le-vert.net/debian jessie main' /etc/apt/sources.list)

        if [[ -z $present ]]; then
                echo "deb http://hwraid.le-vert.net/debian jessie main" >> /etc/apt/sources.list
		wget -O - http://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | sudo apt-key add - 
                apt-get update
                apt-get install megacli -y --force-yes
                apt-get install megactl -y --force-yes
        fi
        echo "MegaCli OK !"
		
	which hdparm > /dev/null
	if [[ $? == 1 ]]; then
		apt-get install hdparm -y --force-yes
	fi
	
	which lshw > /dev/null
	if [[ $? == 1 ]]; then
		apt-get install lshw -y --force-yes
	fi
	
	which curl > /dev/null
	if [[ $? == 1 ]]; then
		apt-get install curl -y --force-yes
	fi
}

## Mount disks : each disk is configured in RAID 0
function online_disks {
        megacli -CfgClr -aALL
        megacli -CfgForeign -Clear -aALL
        megacli -CfgEachDskRaid0 WB RA Direct CachedBadBBu -a0
        megacli -CfgEachDskRaid0 WB RA Direct CachedBadBBu -a1
		sleep 25 # Assure all disks are mounted by Linux
}

## Main #######################################################################################################

# rm old log files
rm log.txt 2> /dev/null
rm MegaSAS.log 2> /dev/null
rm disks.txt 2> /dev/null

# install RAID packages and set disks in RAID 0
install_dependencies
online_disks

# Get all Linux disks IDs
disks=$(fdisk -l | egrep -o '\/dev\/sd[a-z]' | sort | uniq)

# Print getted disks IDs
echo "--------------------------------------------------------------------------------------------------------"
echo -e "Disks :\n$disks"
echo "--------------------------------------------------------------------------------------------------------"

# Eraze all disks in separeted processus
for d in $disks; do
        ( eraze_disk $d ) &
done

wait # Wait for all processus

bash disks.sh # Generate disks infos
#bash test_mail.sh # Send mail with disks informations
	
echo "OK !"

echo -e "${GREEN}FINISH !${NO_COLOR}"

