#!/bin/bash
# Author   :    AlicFeng & GuiGos
# Email    :    a@samego.com / guillaue@guigos.com
# Github   :    https://github.com/Gui-Gos/sshAutoLogin


######################################################################
# clear screen
clear
# set color variables for printf or echo
# example 'printf "${Green}"$VARIABLE" or text${ResetColor}\n"'
Black="\e[0;30m"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
Blue="\e[0;34m"
Purple="\e[0;35m"
Cyan="\e[0;36m"
White="\e[0;37m"
Grey="\e[0;39m"
ResetColor="\e[0m"

######################################################################
# banners #
function BANNER1 { # ANSI Shadow
printf "${Blue}███████╗███████╗██╗  ██╗     █████╗ ██╗   ██╗████████╗ ██████╗     ██╗      ██████╗  ██████╗ ██╗███╗   ██╗
██╔════╝██╔════╝██║  ██║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
███████╗███████╗███████║    ███████║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
╚════██║╚════██║██╔══██║    ██╔══██║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██║   ██║██║██║╚██╗██║
███████║███████║██║  ██║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
╚══════╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝\n"
}

function BANNER2 { # ANSI Regular
printf "██████  ██    ██      ██████  ██    ██ ██  ██████   ██████  ███████ 
██   ██  ██  ██      ██       ██    ██ ██ ██       ██    ██ ██      
██████    ████       ██   ███ ██    ██ ██ ██   ███ ██    ██ ███████ 
██   ██    ██        ██    ██ ██    ██ ██ ██    ██ ██    ██      ██ 
██████     ██         ██████   ██████  ██  ██████   ██████  ███████ \n\n${ResetColor}\n"
}

######################################################################
# check sudo or root perms #
function RootorUser {
	Name=$(whoami)
	printf "${Yellow}Hello '$Name' We will test if you have sudo or root permissions${ResetColor}\n"
	if [ $Name != "root" ]; then
			if ! sudo -l; then
			printf "${Red}'$Name' Is not a sudoers account${ResetColor}\n"
			printf "${Red}Please logged in on a root or admin account and restart the script "$0" ${ResetColor}\n"
			exit 1
			    else
				printf "${Green}'$Name' Is a sudoers account${ResetColor}\n"
			    fi
	else
	printf "${Green}'$Name' Is a good account${ResetColor}\n"
	fi
}

######################################################################
# create configure dir | default in current user .ssha
function ConfigDir {
printf "${Blue}The script is installing the program,Please wating ...${ResetColor}\n"
configureDir=~/.ssha
if [ -d $configureDir ]; then
echo "$configureDir exist."
else
echo "$configureDir does not exist."
sudo mkdir ~/.ssha
fi
localFile=~/.ssha/0_localhost.ini
if [ -f $localFile ]; then
echo "$localFile exist."
sudo rm "$localFile"
printf "Index=0\nName=localhost\nHost=127.0.0.1\nPort=22\nUser=root\nPasswordOrKey=password\n" | sudo tee -a ~/.ssha/0_localhost.ini
else
echo "$localFile does not exist."
printf "Index=0\nName=localhost\nHost=127.0.0.1\nPort=22\nUser=root\nPasswordOrKey=password\n" | sudo tee -a ~/.ssha/0_localhost.ini
fi
}

######################################################################
# check dependencies
function CheckDependencies {
type expect >/dev/null 2>&1 || sudo apt-get install expect -y
type toilet >/dev/null 2>&1 || sudo apt-get install toilet -y
type wget >/dev/null 2>&1 || sudo apt-get install wget -y
}

######################################################################
# install bin & run
function InstallBIN {
Bin="/usr/local/bin/ssha"
if [ -f $Bin ]; then
echo "$Bin exist. Go delete old version!" && sudo rm /usr/local/bin/ssha
fi
sudo wget -O /usr/local/bin/ssha https://raw.githubusercontent.com/Gui-Gos/sshAutoLogin/master/ssha
sudo chmod a+x /usr/local/bin/ssha
toilet -f mono12 -F gay "enjoy ssha" -t
/usr/local/bin/ssha -h
}

######################################################################
# SCRIPT OF INSTALL START HERE #
BANNER1
BANNER2
RootorUser
ConfigDir
CheckDependencies
InstallBIN
