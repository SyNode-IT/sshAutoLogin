#!/bin/bash
# Author   :    AlicFeng & GuiGos
# Email    :    a@samego.com / guillaue@guigos.com
# Github   :    https://github.com/Gui-Gos/sshAutoLogin


######################################################################
### clear screen ###
clear
### set color variables for printf or echo ###
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
### banners ###
function BANNER1 { # ANSI Shadow
printf "${Blue}███████╗███████╗██╗  ██╗     █████╗ ██╗   ██╗████████╗ ██████╗     ██╗      ██████╗  ██████╗ ██╗███╗   ██╗
██╔════╝██╔════╝██║  ██║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
███████╗███████╗███████║    ███████║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
╚════██║╚════██║██╔══██║    ██╔══██║██║   ██║   ██║   ██║   ██║    ██║     ██║   ██║██║   ██║██║██║╚██╗██║
███████║███████║██║  ██║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
╚══════╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝${ResetColor}\n"
}

function BANNER2 { # ANSI Regular
printf "${Blue}██████  ██    ██      ██████  ██    ██ ██  ██████   ██████  ███████ 
██   ██  ██  ██      ██       ██    ██ ██ ██       ██    ██ ██      
██████    ████       ██   ███ ██    ██ ██ ██   ███ ██    ██ ███████ 
██   ██    ██        ██    ██ ██    ██ ██ ██    ██ ██    ██      ██ 
██████     ██         ██████   ██████  ██  ██████   ██████  ███████ \n\n${ResetColor}\n"
}

######################################################################
### check sudo or root perms ###
function RootorUser {
	Name=$(whoami)
	printf "${Yellow}Hello '${Green}$Name${Yellow}' We will test if you have sudo or root permissions${ResetColor}\n"
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
### create configure dir | default in current user .ssha ###
function ConfigDir {
printf "${Blue}The script is installing the program, please wating...${ResetColor}\n"

configureDir=~/.ssha
if [ -d $configureDir ]; then
printf "${Green}$configureDir Exist.${ResetColor}\n"
else
printf "${Green}$configureDir Does not exist, go to create directory.${ResetColor}\n"
sudo mkdir ~/.ssha
fi

localFile=~/.ssha/0_localhost.ini
if [ -f $localFile ]; then
printf "${Green}$localFile Exist.${ResetColor}\n"
sudo rm "$localFile"
printf "Index=0\nName=localhost\nHost=127.0.0.1\nPort=22\nUser=root\nPasswordOrKey=password\n" | sudo tee -a ~/.ssha/0_localhost.ini
else
printf "${Green}$localFile Does not exist, go to create file.${ResetColor}\n"
printf "Index=0\nName=localhost\nHost=127.0.0.1\nPort=22\nUser=root\nPasswordOrKey=password\n" | sudo tee -a ~/.ssha/0_localhost.ini
fi

printf "${Green}Set permissions to $configureDir folder.${ResetColor}\n"
sudo chmod -R 700 $configureDir
sudo chown -R $(whoami) $configureDir
}

######################################################################
### install bin & run ###
function InstallBIN {
Bin="/usr/local/bin/ssha"
if [ -f $Bin ]; then
printf "${Yellow}$Bin Exist. Go delete old version!${ResetColor}\n" && sudo rm /usr/local/bin/ssha
fi
printf "${Green}Installing the SSHA binary.${ResetColor}\n"
sudo wget -O /usr/local/bin/ssha https://raw.githubusercontent.com/Gui-Gos/sshAutoLogin/master/ssha
sudo chmod a+x /usr/local/bin/ssha
printf "${Green}███████╗███╗   ██╗     ██╗ ██████╗ ██╗   ██╗    ███████╗███████╗██╗  ██╗ █████╗ 
██╔════╝████╗  ██║     ██║██╔═══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██║  ██║██╔══██╗
█████╗  ██╔██╗ ██║     ██║██║   ██║ ╚████╔╝     ███████╗███████╗███████║███████║
██╔══╝  ██║╚██╗██║██   ██║██║   ██║  ╚██╔╝      ╚════██║╚════██║██╔══██║██╔══██║
███████╗██║ ╚████║╚█████╔╝╚██████╔╝   ██║       ███████║███████║██║  ██║██║  ██║
╚══════╝╚═╝  ╚═══╝ ╚════╝  ╚═════╝    ╚═╝       ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝${ResetColor}\n"
/usr/local/bin/ssha -h
}

######################################################################
### detect os ###
function DetectOS {
# Mac OS
MacOS=$(uname -a | grep -c MacOS)
Darwin=$(uname -a | grep -c Darwin)
# Debian
Debian=$(uname -a | grep -c Debian)
Ubuntu=$(uname -a | grep -c Ubuntu)
# Redhat
CentOS=$(uname -a | grep -c CentOS)
Fedora=$(uname -a | grep -c Fedora)
OpenSuse=$(uname -a | grep -c OpenSuse)
RedHat=$(uname -a | grep -c RedHat)
if [ $MacOS -gt 0 ] || [ $Darwin -gt 0 ]; then
OS="MacOS"
fi
if [ $Debian -gt 0 ] || [ $Ubuntu -gt 0 ]; then
OS="Debian"
fi
if [ $RedHat -gt 0 ] || [ $Fedora -gt 0 ] || [ $OpenSuse -gt 0 ] || [ $CentOS -gt 0 ]; then
OS="RedHat"
fi
}

######################################################################
### check dependencies ###
# for debian
function CheckDependencies_Debian {
printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
printf "${Green}Test of existing binaries (expect,toilet,wget) and installation of this one if they are not installed...${ResetColor}\n"
type expect >/dev/null 2>&1 || sudo apt-get install expect -y
type toilet >/dev/null 2>&1 || sudo apt-get install toilet -y
type wget >/dev/null 2>&1 || sudo apt-get install wget -y
}
# for macos
function CheckDependencies_MacOS {
printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
printf "${Green}Test of existing binaries (brew,expect,toilet,wget) and installation of this one if they are not installed...${ResetColor}\n"
type brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
sudo chown -R $(whoami) /usr/local/bin
sudo chmod u+w /usr/local/bin
brew update --auto-update
brew upgrade
type expect >/dev/null 2>&1 || brew install expect
type toilet >/dev/null 2>&1 || brew install toilet
type wget >/dev/null 2>&1 || brew install wget
}
# for redhat
function CheckDependencies_RedHat {
printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
printf "${Green}Test of existing binaries (expect,toilet,wget) and installation of this one if they are not installed...${ResetColor}\n"
type expect >/dev/null 2>&1 || sudo yum install expect -y
type toilet >/dev/null 2>&1 || sudo yum install toilet -y
type wget >/dev/null 2>&1 || sudo yum install wget -y
}

######################################################################
# SCRIPT OF INSTALL START HERE #
BANNER1
BANNER2
DetectOS
RootorUser
ConfigDir
CheckDependencies_$OS
InstallBIN
