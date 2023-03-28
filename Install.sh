#!/bin/bash
# Author   :    GuGus
# Email    :    guillaume@guigos.com
# Github   :    https://github.com/o-GuGus/sshAutoLogin

###########################################
### Terminal Colors and Screen Clearing ###
clear
# set color variables for 'printf' or 'echo'
# example 'printf "${Green}"$VARIABLE" or text${ResetColor}\n"'
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
Blue="\e[0;34m"
ResetColor="\e[0m"

######################################
### Banners with ASCII art in Bash ###
function BANNER1 { # ANSI Shadow
printf "${Blue}███████╗███████╗██╗  ██╗
██╔════╝██╔════╝██║  ██║
███████╗███████╗███████║
╚════██║╚════██║██╔══██║
███████║███████║██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝${ResetColor}\n"

printf "${Blue}	 █████╗ ██╗   ██╗████████╗ ██████╗ 
	██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗
	███████║██║   ██║   ██║   ██║   ██║
	██╔══██║██║   ██║   ██║   ██║   ██║
	██║  ██║╚██████╔╝   ██║   ╚██████╔╝
	╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝${ResetColor}\n" 

printf "${Blue}		██╗      ██████╗  ██████╗ ██╗███╗   ██╗
		██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
		██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
		██║     ██║   ██║██║   ██║██║██║╚██╗██║
		███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
		╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝${ResetColor}\n"
}

function BANNER2 { # ANSI Regular
printf "${Blue}██████  ██    ██      ██████  ██    ██  ██████  ██    ██ ███████ 
██   ██  ██  ██      ██       ██    ██ ██       ██    ██ ██      
██████    ████       ██   ███ ██    ██ ██   ███ ██    ██ ███████ 
██   ██    ██        ██    ██ ██    ██ ██    ██ ██    ██      ██ 
██████     ██         ██████   ██████   ██████   ██████  ███████\n\n${ResetColor}\n"
}

###########################################################################################
### This function allows to detect the operating system on which the script is executed ###
function DetectOS {
  # If the system is MacOS, we set the OS variable to "MacOS"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    OS="MacOS"
  # If the system is Debian, Ubuntu or Mint, we set the OS variable to "Debian"
  elif [[ "$(cat /etc/issue)" == *"Debian"* || "$(cat /etc/issue)" == *"Ubuntu"* || "$(cat /etc/issue)" == *"Mint"* ]]; then
    OS="Debian"
  # If the system is Red Hat, CentOS, Fedora or OpenSUSE, we set the OS variable to "RedHat"
  elif [[ "$(cat /etc/issue)" == *"Red Hat"* || "$(cat /etc/issue)" == *"CentOS"* || "$(cat /etc/issue)" == *"Fedora"* || "$(cat /etc/issue)" == *"OpenSUSE"* ]]; then
    OS="RedHat"
  fi
}

######################################################
### Function to Check for sudo or root permissions ###
function RootorUser {
	# Get the current user's name
	Name=$(whoami)
	# Print a message to indicate that the script is checking for sudo or root permissions
	printf "${Yellow}Hello '${Green}$Name${Yellow}' We will test if you have sudo or root permissions${ResetColor}\n"
	# Check if the current user is not root
	if [ "$Name" != "root" ]; then
		# Check if the user has sudo privileges
		if ! sudo -l; then
			# If the user does not have sudo privileges, print an error message and exit the script
			printf "${Red}'$Name' Is not a sudoers account${ResetColor}\n"
			printf "${Red}Please log in as a root or admin account and restart the script '$0'${ResetColor}\n"
			exit 1
		else
			# If the user has sudo privileges, print a success message
			printf "${Green}'$Name' Is a sudoers account${ResetColor}\n"
		fi
	else
		# If the user is root, print a success message
		printf "${Green}'$Name' Is a good account${ResetColor}\n"
	fi
}

################################################################
### Function to configure directory and file for the program ###
function ConfigDir {
  # Print message indicating the program is being installed
  printf "${Blue}The script is installing the program, please wait...${ResetColor}\n"
  # Set the configuration directory
  Config_Dir=~/.ssha
  # Check if configuration directory exists
  if [ -d $Config_Dir ]; then
    printf "${Green}$Config_Dir Folder exist.${ResetColor}\n"
  else
    # Create configuration directory if it doesn't exist
    printf "${Green}$Config_Dir Folder does not exist, creating directory.${ResetColor}\n"
    sudo mkdir $Config_Dir
  fi
  # Set the configuration file for localhost
  localFile=$Config_Dir/0_localhost.ini
  if [ -f $localFile ]; then
    # If configuration file exists, remove it and create a new one
    printf "${Green}$localFile Exist.${ResetColor}\n"
    sudo rm "$localFile"
  else
    # If configuration file doesn't exist, create a new one
    printf "${Green}$localFile Does not exist, creating file.${ResetColor}\n"
  fi
  printf "Index=0\nName=localhost\nHost=127.0.0.1\nPort=22\nUser=root\nPasswordOrKey=password\n" > $localFile
  sudo chmod -R 700 $Config_Dir
  sudo chown -R "$(whoami)" $Config_Dir
}

########################################################################################
### Functions for Operating system specific dependency check and installation script ###
# CheckDependencies_Debian function for Debian-based systems
function CheckDependencies_Debian {
    # Print OS information
    printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
    # Print message for testing and installing dependencies
    printf "${Green}Testing existing binaries (expect, wget) and installing missing ones...${ResetColor}\n"
    # Check for and install expect and wget
    type expect >/dev/null 2>&1 || sudo apt-get install expect -y
    type wget >/dev/null 2>&1 || sudo apt-get install wget -y
}
# CheckDependencies_MacOS function for MacOS
function CheckDependencies_MacOS {
    # Print OS information
    printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
    # Print message for testing and installing dependencies
    printf "${Green}Testing existing binaries (brew, expect, wget) and installing missing ones...${ResetColor}\n"
    # Check for and install brew
    type brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Set permissions for /usr/local/bin
    sudo chown -R "$(whoami)" /usr/local/bin
    sudo chmod u+w /usr/local/bin
    # Update and upgrade brew and install expect and wget
    brew update --auto-update
    brew upgrade
    type expect >/dev/null 2>&1 || brew install expect
    type wget >/dev/null 2>&1 || brew install wget
}
# CheckDependencies_RedHat function for RedHat-based systems
function CheckDependencies_RedHat {
    # Print OS information
    printf "${Yellow}This machine works with OS based on ${Green}$OS${ResetColor}\n"
    # Print message for testing and installing dependencies
    printf "${Green}Testing existing binaries (expect, wget) and installing missing ones...${ResetColor}\n"
    # Check for and install expect and wget
    type expect >/dev/null 2>&1 || sudo yum install expect -y
    type wget >/dev/null 2>&1 || sudo yum install wget -y
}

#########################################################################
### Function for installation of SSHA binary with output confirmation ###
# Install and run the SSHA binary
function InstallBIN {
  Bin="/usr/local/bin/ssha"
  # Check if the binary exists and remove it if it does
  if [ -f $Bin ]; then
    printf "${Yellow}$Bin Exist. Go delete old version!${ResetColor}\n" && sudo rm /usr/local/bin/ssha
  fi
  # Download and install the SSHA binary
  printf "${Green}Installing the SSHA binary.${ResetColor}\n"
  sudo wget -O /usr/local/bin/ssha https://raw.githubusercontent.com/o-GuGus/sshAutoLogin/master/ssha
  sudo chmod a+x /usr/local/bin/ssha
  # Print the SSHA logo and display the help menu
  printf "${Green}███████╗███╗   ██╗     ██╗ ██████╗ ██╗   ██╗    ███████╗███████╗██╗  ██╗ █████╗ 
██╔════╝████╗  ██║     ██║██╔═══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██║  ██║██╔══██╗
█████╗  ██╔██╗ ██║     ██║██║   ██║ ╚████╔╝     ███████╗███████╗███████║███████║
██╔══╝  ██║╚██╗██║██   ██║██║   ██║  ╚██╔╝      ╚════██║╚════██║██╔══██║██╔══██║
███████╗██║ ╚████║╚█████╔╝╚██████╔╝   ██║       ███████║███████║██║  ██║██║  ██║
╚══════╝╚═╝  ╚═══╝ ╚════╝  ╚═════╝    ╚═╝       ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝${ResetColor}\n"
  /usr/local/bin/ssha -h
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
