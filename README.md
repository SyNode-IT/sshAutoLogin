# SSHA

SSHA est un gestionnaire CLI pour connexions SSH interactives avec stockage local chiffré des secrets.

Le projet supporte deux modes d'authentification :

- mot de passe SSH
- chemin de clé privée SSH

Pour une clé privée chiffrée, `ssha` transmet le fichier à `ssh` puis laisse OpenSSH demander la passphrase de façon interactive.

## Points clés

- stockage local dans `~/.ssha`
- mot de passe maître avec dérivation PBKDF2
- secrets chiffrés et authentifiés (HMAC)
- migration automatique du fichier maître legacy
- migration explicite des anciens secrets via `ssha -m`
- sauvegarde/restauration avec contrôles d'intégrité structurelle
- CI macOS + Linux

## Installation

### Depuis une release GitHub

Le script d'installation récupère uniquement des artefacts de release taggés, jamais la branche `master`.

```bash
curl -fsSL https://raw.githubusercontent.com/o-GuGus/sshAutoLogin/v2.1.0/install.sh | bash
```

Variables utiles :

- `SSHA_INSTALL_VERSION=v2.1.0` pour forcer une release
- `SSHA_INSTALL_DIR=/usr/local/bin` pour changer le répertoire d'installation
- `SSHA_GITHUB_REPO=o-GuGus/sshAutoLogin` pour pointer vers un fork

### Depuis ce dépôt local

```bash
./install.sh
```

Dans ce cas, `install.sh` vérifie d'abord le couple local `ssha` / `ssha.sha256`, puis installe le binaire.

## Usage

```bash
ssha -h
ssha -c
ssha -l
ssha -s 0
ssha -b weekly
ssha --list-backups
ssha -r ~/.ssha/.backups/weekly.tar.gz
ssha -m
```

## Fichiers

- `ssha` : binaire shell principal
- `install.sh` : installateur local ou release
- `tests/smoke.sh` : smoke test end-to-end
- `tests/verify_checksum.sh` : vérifie que `ssha.sha256` correspond au binaire
- `scripts/update_sha256.sh` : régénère `ssha.sha256`

## Sécurité

- Le mot de passe maître n'est jamais stocké en clair.
- Les secrets sont chiffrés localement et signés avant écriture.
- Les nouvelles connexions utilisent `StrictHostKeyChecking=accept-new`.
- La restauration rejette les archives contenant des chemins dangereux ou des liens symboliques.

Ce projet reste un utilitaire shell interactif. Il n'a pas vocation à remplacer un gestionnaire de secrets centralisé ou un bastion SSH.

## Release

Avant de publier une release :

```bash
scripts/update_sha256.sh
tests/verify_checksum.sh
tests/smoke.sh
shellcheck -S error -x ssha install.sh tests/verify_checksum.sh tests/smoke.sh
```

Puis :

1. créer un tag Git `vX.Y.Z`
2. publier les artefacts `ssha`, `ssha.sha256` et `install.sh` dans la release
3. vérifier qu'un hôte Linux et un hôte macOS propres peuvent installer la version
