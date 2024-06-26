#!/bin/bash
# Authors   :    AlicFeng & GuGus
# Emails    :    a@samego.com / guillaume@guigos.com
# Githubs   :    https://github.com/alicfeng/sshAutoLogin / https://github.com/o-GuGus/sshAutoLogin

# Terminal Colors
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
Blue="\e[0;34m"
ResetColor="\e[0m"

# Banner Function
function Banner {
    printf "${Blue}
███████╗███████╗██╗  ██╗     █████╗ ██╗   ██╗████████╗ ██████╗ 
██╔════╝██╔════╝██║  ██║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗
███████╗███████╗███████║    ███████║██║   ██║   ██║   ██║   ██║
╚════██║╚════██║██╔══██║    ██╔══██║██║   ██║   ██║   ██║   ██║
███████║███████║██║  ██║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝
╚══════╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ 
                                                               
██╗      ██████╗  ██████╗ ██╗███╗   ██╗
██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
██║     ██║   ██║██║   ██║██║██║╚██╗██║
███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝
${ResetColor}\n"
}

# Detect OS Function
function DetectOS {
    printf "🔍 ${Blue}Détection du système d'exploitation...${ResetColor}\n"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        OS="MacOS"
    elif [[ -f /etc/debian_version ]]; then
        OS="Debian"
    elif [[ -f /etc/redhat-release ]]; then
        OS="RedHat"
    else
        OS="Unknown"
    fi
    printf "✅ ${Green}Système d'exploitation détecté : $OS${ResetColor}\n"
}

# Check Root or Sudo Function
function CheckRootOrSudo {
    printf "🔐 ${Blue}Vérification des privilèges...${ResetColor}\n"
    if [[ $EUID -ne 0 ]]; then
        if ! sudo -v &> /dev/null; then
            printf "❌ ${Red}Ce script doit être exécuté avec des privilèges sudo. Veuillez l'exécuter en tant que root ou utiliser sudo.${ResetColor}\n"
            exit 1
        fi
    fi
    printf "✅ ${Green}Privilèges suffisants détectés.${ResetColor}\n"
}

# Configure Directory Function
function ConfigureDirectory {
    printf "📁 ${Blue}Configuration du répertoire...${ResetColor}\n"
    Config_Dir=~/.ssha
    if [[ ! -d $Config_Dir ]]; then
        printf "${Yellow}Création du répertoire $Config_Dir${ResetColor}\n"
        mkdir -p $Config_Dir
    fi
    chmod 700 $Config_Dir
    chown $(whoami) $Config_Dir
    printf "✅ ${Green}Répertoire configuré avec succès.${ResetColor}\n"
}

# Install Dependencies Function
function InstallDependencies {
    printf "🔧 ${Blue}Vérification des dépendances...${ResetColor}\n"
    case $OS in
        "Debian"|"RedHat")
            missing_deps=()
            for dep in bash openssl expect ssh sed; do
                if ! command -v $dep &> /dev/null; then
                    missing_deps+=($dep)
                fi
            done
            
            if [ ${#missing_deps[@]} -eq 0 ]; then
                printf "✅ ${Green}Toutes les dépendances nécessaires sont déjà installées.${ResetColor}\n"
            else
                printf "📦 ${Yellow}Installation des dépendances manquantes : ${missing_deps[*]}${ResetColor}\n"
                if [ "$OS" = "Debian" ]; then
                    sudo apt-get update
                    sudo apt-get install -y ${missing_deps[@]} openssh-client
                else
                    sudo yum update
                    sudo yum install -y ${missing_deps[@]} openssh-clients
                fi
                printf "✅ ${Green}Dépendances installées avec succès.${ResetColor}\n"
            fi
            ;;
        "MacOS")
            if ! command -v expect &> /dev/null || ! command -v openssl &> /dev/null; then
                printf "⚠️ ${Yellow}Expect ou OpenSSL non trouvé. Vérifiez votre installation macOS.${ResetColor}\n"
                printf "${Yellow}Si nécessaire, installez les outils de développement en exécutant :${ResetColor}\n"
                printf "${Green}xcode-select --install${ResetColor}\n"
                exit 1
            else
                printf "✅ ${Green}Toutes les dépendances nécessaires sont déjà installées sur macOS.${ResetColor}\n"
            fi
            ;;
        *)
            printf "❌ ${Red}Système d'exploitation non supporté. Veuillez installer les dépendances manuellement.${ResetColor}\n"
            exit 1
            ;;
    esac
}

# Install SSHA Binary Function
function InstallSSHABinary {
    printf "📥 ${Blue}Installation du binaire SSHA...${ResetColor}\n"
    Bin="/usr/local/bin/ssha"
    if [[ -f $Bin ]]; then
        printf "🔄 ${Yellow}Suppression de l'ancienne version de SSHA${ResetColor}\n"
        sudo rm $Bin
    fi
    sudo curl -o $Bin https://raw.githubusercontent.com/o-GuGus/sshAutoLogin/master/ssha
    sudo chmod a+x $Bin
    printf "✅ ${Green}SSHA installé avec succès !${ResetColor}\n"
    $Bin -h
}

# Main Execution
Banner
DetectOS
CheckRootOrSudo
ConfigureDirectory
InstallDependencies
InstallSSHABinary

printf "🎉 ${Green}Installation terminée. Vous pouvez maintenant utiliser la commande 'ssha'.${ResetColor}\n"
