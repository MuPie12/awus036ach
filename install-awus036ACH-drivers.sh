#!/bin/bash

if [ `id -u` -ne 0 ];then
    echo "[-] Run this script as root!"
else

    echo "[*] Installing  ..."

#get The OS name
    os=`cat /etc/os-release | awk 'BEGIN{FS="="}/ID/{if(NR==3) print $2}'`  
    is_os_debian_based=`cat /etc/os-release | awk 'BEGIN{FS="="}/ID_LIKE/{print $2}'  | grep "debian" > /dev/null  && echo "True" || echo "False"`

#if ArchLinux
    if [ $os == "arch" ];then
        # update your repositories
        echo "[*] wait a while while updating your repos ..."
        yes | pacman -Syy > /dev/null
        echo " [+] repos updated ! "

        # install dkms if it isn't already
        echo "[*] Installing dkms ..."
        yes | pacman -Sy dkms > /dev/null
        echo "[+] dkms installed!"

#if Debian based:
    elif [[ $is_os_debian_based == "True" ]];then 
        # update the repositories
        echo "[*] updating your repos ..."
        apt update -y > /dev/null 2>&1 
        apt upgrade -y > /dev/null 2>&1
        echo " [+] repos updated ! "

        #install dkms
        echo "[*] Installing dkms ..."
        apt install dkms > /dev/null
        echo "[+] dkms installed !"
    fi
# change directory to /usr/src
    cd /usr/src

# if you have any other drivers installed,remove them like so:
    rm -r rtl8812AU*/ > /dev/null 2>&1

# get latest driver from github

    echo "[*] Downloading drivers ..."
    git clone https://github.com/gordboy/rtl8812au-5.6.4.2 > /dev/null 2>&1
    echo "[+] Drivers Downloaded ! "

# move into downloaded driver folder
    cd rtl8812au*/

# make drivers
    echo "[*] Making  drivers ..."
    make > /dev/null
    sudo make install > /dev/null


# move into parent directory
    cd ..

# dkms add driver
    echo "[*] Adding drivers to dkms"
    dkms add -m rtl8812au -v 5.6.4.2 2> /dev/null

# build drivers
    echo "[*]building drivers to dkms"
    dkms build -m rtl8812au -v 5.6.4.2 > /dev/null 

# install drivers
    echo "[*]installing drivers to dkms"
    dkms install -m rtl8812au -v 5.6.4.2 2> /dev/null


# summon new interface from the depths of the kernel
    modprobe 8812au > /dev/null

    echo " [+] Done! "

fi
