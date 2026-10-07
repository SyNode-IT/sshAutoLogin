#!/usr/bin/env bash

readonly VERSION="2.1.0"
readonly DEFAULT_RELEASE_VERSION="v2.1.0"
readonly DEFAULT_GITHUB_REPO="o-GuGus/sshAutoLogin"
readonly DEFAULT_INSTALL_DIR="/usr/local/bin"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOCAL_BIN="${SCRIPT_DIR}/ssha"
readonly LOCAL_SHA="${SCRIPT_DIR}/ssha.sha256"
readonly INSTALL_DIR="${SSHA_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
readonly TARGET_BIN="${INSTALL_DIR}/ssha"
readonly RELEASE_VERSION="${SSHA_INSTALL_VERSION:-$DEFAULT_RELEASE_VERSION}"
readonly GITHUB_REPO="${SSHA_GITHUB_REPO:-$DEFAULT_GITHUB_REPO}"

Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
Blue="\e[0;34m"
ResetColor="\e[0m"

Banner() {
    printf "${Blue}SSHA installer${ResetColor} (version %s)\n" "$VERSION"
}

Info() {
    printf "ℹ️  %b%s%b\n" "$Blue" "$1" "$ResetColor"
}

Success() {
    printf "✅ %b%s%b\n" "$Green" "$1" "$ResetColor"
}

Warn() {
    printf "⚠️  %b%s%b\n" "$Yellow" "$1" "$ResetColor"
}

Fail() {
    printf "❌ %b%s%b\n" "$Red" "$1" "$ResetColor" >&2
}

DetectOS() {
    Info "Détection du système d'exploitation..."
    if [[ "$(uname -s)" == "Darwin" ]]; then
        OS="MacOS"
    elif [[ -f /etc/debian_version ]]; then
        OS="Debian"
    elif [[ -f /etc/redhat-release ]]; then
        OS="RedHat"
    else
        OS="Unknown"
    fi
    Success "Système d'exploitation détecté : ${OS}"
}

RunPrivileged() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        if ! command -v sudo >/dev/null 2>&1; then
            Fail "sudo est requis pour exécuter : $*"
            exit 1
        fi
        sudo "$@"
    fi
}

RunMaybePrivileged() {
    local target_path="$1"
    shift
    local writable_base="$target_path"

    if [[ ! -e "$writable_base" ]]; then
        writable_base="$(dirname "$writable_base")"
    fi

    if [[ $EUID -eq 0 || -w "$writable_base" ]]; then
        "$@"
    else
        RunPrivileged "$@"
    fi
}

Sha256File() {
    local target="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$target" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$target" | awk '{print $1}'
    else
        Fail "sha256sum/shasum est requis pour vérifier l'intégrité."
        exit 1
    fi
}

InstallDependencies() {
    Info "Vérification des dépendances..."

    case "$OS" in
        "Debian")
            local missing=()
            for dep in bash openssl expect ssh curl awk install; do
                if ! command -v "$dep" >/dev/null 2>&1; then
                    missing+=("$dep")
                fi
            done

            if [[ ${#missing[@]} -eq 0 ]]; then
                Success "Toutes les dépendances nécessaires sont déjà installées."
                return 0
            fi

            Info "Installation des dépendances manquantes via apt-get..."
            RunPrivileged apt-get update
            RunPrivileged apt-get install -y bash curl expect openssh-client openssl coreutils
            ;;
        "RedHat")
            local missing=()
            for dep in bash openssl expect ssh curl awk install; do
                if ! command -v "$dep" >/dev/null 2>&1; then
                    missing+=("$dep")
                fi
            done

            if [[ ${#missing[@]} -eq 0 ]]; then
                Success "Toutes les dépendances nécessaires sont déjà installées."
                return 0
            fi

            Info "Installation des dépendances manquantes via yum..."
            RunPrivileged yum install -y bash coreutils curl expect openssh-clients openssl
            ;;
        "MacOS")
            local missing=()
            for dep in openssl expect curl ssh; do
                if ! command -v "$dep" >/dev/null 2>&1; then
                    missing+=("$dep")
                fi
            done

            if [[ ${#missing[@]} -eq 0 ]]; then
                Success "Toutes les dépendances nécessaires sont déjà installées sur macOS."
                return 0
            fi

            if command -v brew >/dev/null 2>&1; then
                Info "Installation des dépendances manquantes via Homebrew..."
                if [[ " ${missing[*]} " == *" expect "* ]]; then
                    brew install expect
                fi
                if [[ " ${missing[*]} " == *" openssl "* ]]; then
                    brew install openssl@3
                fi
                if [[ " ${missing[*]} " == *" curl "* ]]; then
                    brew install curl
                fi
            else
                Fail "Homebrew est requis sur macOS pour installer automatiquement expect/openssl/curl."
                printf "Installez Homebrew puis relancez ce script, ou installez manuellement : brew install expect openssl@3 curl\n" >&2
                exit 1
            fi
            ;;
        *)
            Fail "Système d'exploitation non supporté. Veuillez installer les dépendances manuellement."
            exit 1
            ;;
    esac

    Success "Dépendances installées avec succès."
}

CopyLocalSource() {
    local destination_bin="$1"
    local destination_sha="$2"

    [[ -f "$LOCAL_BIN" && -f "$LOCAL_SHA" ]] || return 1

    Info "Utilisation de la source locale vérifiée depuis ${SCRIPT_DIR}."
    cp "$LOCAL_BIN" "$destination_bin"
    cp "$LOCAL_SHA" "$destination_sha"
    return 0
}

DownloadReleaseSource() {
    local destination_bin="$1"
    local destination_sha="$2"
    local base_url="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_VERSION}"

    Info "Téléchargement de SSHA depuis la release ${RELEASE_VERSION}."
    curl -fsSL -o "$destination_bin" "${base_url}/ssha" || return 1
    curl -fsSL -o "$destination_sha" "${base_url}/ssha.sha256" || return 1
}

InstallSSHABinary() {
    local tmp_bin
    local tmp_sha
    local expected_hash
    local actual_hash

    tmp_bin=$(mktemp "/tmp/ssha.XXXXXX") || exit 1
    tmp_sha=$(mktemp "/tmp/ssha.sha256.XXXXXX") || exit 1
    trap 'rm -f "$tmp_bin" "$tmp_sha"' EXIT

    if ! CopyLocalSource "$tmp_bin" "$tmp_sha"; then
        if ! DownloadReleaseSource "$tmp_bin" "$tmp_sha"; then
            Fail "Impossible de récupérer SSHA depuis la release ${RELEASE_VERSION}."
            exit 1
        fi
    fi

    expected_hash=$(awk '{print $1}' "$tmp_sha")
    actual_hash=$(Sha256File "$tmp_bin")

    if [[ -z "$expected_hash" || "$expected_hash" != "$actual_hash" ]]; then
        Fail "Échec de la vérification SHA256."
        printf "Attendu : %s\nObtenu  : %s\n" "$expected_hash" "$actual_hash" >&2
        exit 1
    fi

    Success "Intégrité du binaire vérifiée."
    RunMaybePrivileged "$INSTALL_DIR" mkdir -p "$INSTALL_DIR"
    RunMaybePrivileged "$TARGET_BIN" install -m 0755 "$tmp_bin" "$TARGET_BIN"
    Success "SSHA installé avec succès dans ${TARGET_BIN}."

    trap - EXIT
    rm -f "$tmp_bin" "$tmp_sha"
    "${TARGET_BIN}" -v
}

Banner
DetectOS
InstallDependencies
InstallSSHABinary

Success "Installation terminée. La commande 'ssha' est prête."
