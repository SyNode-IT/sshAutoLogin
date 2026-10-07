#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSHA_BIN="${ROOT_DIR}/ssha"

mktemp_dir() {
    mktemp -d 2>/dev/null || mktemp -d -t ssha-smoke
}

TEST_HOME="$(mktemp_dir)"
LOG_DIR="$(mktemp_dir)"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
    rm -rf "${TEST_HOME}" "${LOG_DIR}"
}
trap cleanup EXIT

pass() {
    printf "PASS: %s\n" "$1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    printf "FAIL: %s\n" "$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

if [[ ! -x "${SSHA_BIN}" ]]; then
    echo "FAIL: binaire introuvable ou non exécutable: ${SSHA_BIN}"
    exit 1
fi

HOME="${TEST_HOME}" "${SSHA_BIN}" -h >"${LOG_DIR}/help.out" 2>&1 || true
if [[ ! -d "${TEST_HOME}/.ssha" ]]; then
    pass "-h sans effet de bord"
else
    fail "-h ne doit pas créer ~/.ssha"
fi

HOME="${TEST_HOME}" "${SSHA_BIN}" -v >"${LOG_DIR}/version.out" 2>&1 || true
if [[ ! -d "${TEST_HOME}/.ssha" ]]; then
    pass "-v sans effet de bord"
else
    fail "-v ne doit pas créer ~/.ssha"
fi

MASTER_PASS='StrongPass1!!'

HOME="${TEST_HOME}" "${SSHA_BIN}" -l >"${LOG_DIR}/list_empty.out" 2>&1 || true
if [[ -d "${TEST_HOME}/.ssha" ]]; then
    pass "-l crée ~/.ssha"
else
    fail "-l doit créer ~/.ssha"
fi
if [[ -z "$(find "${TEST_HOME}/.ssha" -maxdepth 1 -type f -print -quit)" ]]; then
    pass "aucun fichier serveur par défaut invalide"
else
    fail "des fichiers inattendus existent dans ~/.ssha"
fi

printf '%s\n%s\nsrv1\n127.0.0.1\n1\nalice\np\nsecret1\no\n' "${MASTER_PASS}" "${MASTER_PASS}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -c >"${LOG_DIR}/create1.out" 2>&1 || true
if [[ -f "${TEST_HOME}/.ssha/.master_key" ]]; then
    pass "création du fichier master key"
else
    fail "fichier master key manquant"
fi
if grep -q '^salt=' "${TEST_HOME}/.ssha/.master_key" && grep -q '^verifier=' "${TEST_HOME}/.ssha/.master_key" && grep -q '^iterations=' "${TEST_HOME}/.ssha/.master_key" && ! grep -q '^hash=' "${TEST_HOME}/.ssha/.master_key"; then
    pass "format master key valide (multiligne key=value)"
else
    fail "format master key invalide"
fi
if [[ -f "${TEST_HOME}/.ssha/0_srv1.conf" ]]; then
    pass "création du premier serveur"
else
    fail "fichier du premier serveur manquant"
fi
if grep -q '^Name=srv1$' "${TEST_HOME}/.ssha/0_srv1.conf"; then
    pass "format serveur valide (multiligne key=value)"
else
    fail "format du fichier serveur invalide"
fi
if grep -q '^AuthType=password$' "${TEST_HOME}/.ssha/0_srv1.conf"; then
    pass "type d'authentification password persisté"
else
    fail "type d'authentification password manquant"
fi
SECRET_FILE="$(find "${TEST_HOME}/.ssha/.data" -type f | head -1)"
if grep -q '^auth_type=password$' "${SECRET_FILE}" && grep -q '^mac=' "${SECRET_FILE}"; then
    pass "secret chiffré signé et typé"
else
    fail "secret chiffré incomplet"
fi

LEGACY_SALT="$(grep '^salt=' "${TEST_HOME}/.ssha/.master_key" | cut -d'=' -f2)"
LEGACY_HASH="$(printf "%s" "${MASTER_PASS}${LEGACY_SALT}" | openssl dgst -sha256 | awk '{print $NF}')"
printf 'salt=%s\nhash=%s\nversion=2.0.0\n' "${LEGACY_SALT}" "${LEGACY_HASH}" >"${TEST_HOME}/.ssha/.master_key"
chmod 600 "${TEST_HOME}/.ssha/.master_key"
printf '%s\n' "${MASTER_PASS}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -s 0 >"${LOG_DIR}/master_upgrade.out" 2>&1 || true
if grep -q '^verifier=' "${TEST_HOME}/.ssha/.master_key" && grep -q '^iterations=' "${TEST_HOME}/.ssha/.master_key" && ! grep -q '^hash=' "${TEST_HOME}/.ssha/.master_key"; then
    pass "upgrade auto du master key legacy"
else
    fail "upgrade auto du master key legacy absent"
fi

printf '%s\nsrv2\n192.168.0.10\n22\nbob\np\nsecret2\no\n' "${MASTER_PASS}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -c >"${LOG_DIR}/create2.out" 2>&1 || true
if grep -q "Mot de passe maître incorrect" "${LOG_DIR}/create2.out"; then
    fail "vérification du mot de passe maître en 2e exécution"
else
    pass "vérification du mot de passe maître en 2e exécution"
fi
if [[ -f "${TEST_HOME}/.ssha/1_srv2.conf" ]]; then
    pass "index non-collision sur le 2e serveur"
else
    fail "index serveur incorrect sur le 2e serveur"
fi

HOME="${TEST_HOME}" "${SSHA_BIN}" -l >"${LOG_DIR}/list_after_create.out" 2>&1 || true
if grep -q 'srv1' "${LOG_DIR}/list_after_create.out" && grep -q 'srv2' "${LOG_DIR}/list_after_create.out"; then
    pass "listing des serveurs correct"
else
    fail "listing des serveurs incomplet"
fi
if grep -q 'password' "${LOG_DIR}/list_after_create.out"; then
    pass "listing affiche le type d'authentification"
else
    fail "listing n'affiche pas le type d'authentification"
fi

FAKE_KEY="${TEST_HOME}/id_ed25519"
printf 'not-a-real-key\n' >"${FAKE_KEY}"
chmod 600 "${FAKE_KEY}"
printf '%s\nsrvkey\n10.0.0.8\n22\ncarol\nk\n%s\no\n' "${MASTER_PASS}" "${FAKE_KEY}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -c >"${LOG_DIR}/create_key.out" 2>&1 || true
if [[ -f "${TEST_HOME}/.ssha/2_srvkey.conf" ]] && grep -q '^AuthType=key_file$' "${TEST_HOME}/.ssha/2_srvkey.conf"; then
    pass "création d'un serveur à clé"
else
    fail "création d'un serveur à clé"
fi

printf '%s\n' "${MASTER_PASS}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -s 0 >"${LOG_DIR}/login.out" 2>&1 || true
if grep -q "Mot de passe maître incorrect" "${LOG_DIR}/login.out"; then
    fail "connexion refuse un mot de passe maître valide"
else
    pass "connexion accepte le mot de passe maître"
fi
if grep -q "Impossible de déchiffrer" "${LOG_DIR}/login.out" || grep -q "Intégrité du secret compromise" "${LOG_DIR}/login.out"; then
    fail "déchiffrement du secret serveur"
else
    pass "déchiffrement du secret serveur"
fi

HOME="${TEST_HOME}" "${SSHA_BIN}" -b base >"${LOG_DIR}/backup.out" 2>&1 || true
if [[ -f "${TEST_HOME}/.ssha/.backups/base.tar.gz" ]]; then
    pass "backup créé"
else
    fail "backup manquant"
fi
if tar -tzf "${TEST_HOME}/.ssha/.backups/base.tar.gz" | grep -q '^./.backups'; then
    fail "le backup ne doit pas inclure .backups"
else
    pass "le backup exclut .backups"
fi
HOME="${TEST_HOME}" "${SSHA_BIN}" -b ../bad >"${LOG_DIR}/backup_bad_name.out" 2>&1 || true
if grep -q 'Nom de sauvegarde invalide' "${LOG_DIR}/backup_bad_name.out"; then
    pass "validation du nom de sauvegarde"
else
    fail "nom de sauvegarde invalide accepté"
fi

HOME="${TEST_HOME}" "${SSHA_BIN}" --list-backups >"${LOG_DIR}/list_backups.out" 2>&1 || true
if grep -q 'base.tar.gz' "${LOG_DIR}/list_backups.out"; then
    pass "--list-backups fonctionne"
else
    fail "--list-backups n'affiche pas l'archive attendue"
fi

printf 'Index=9\nName=stale\nHost=1.1.1.1\nPort=22\nUser=u\nPasswordOrKey=x\n' >"${TEST_HOME}/.ssha/stale.conf"
printf 'o\n' | HOME="${TEST_HOME}" "${SSHA_BIN}" -r "${TEST_HOME}/.ssha/.backups/base.tar.gz" >"${LOG_DIR}/restore.out" 2>&1 || true
if [[ ! -f "${TEST_HOME}/.ssha/stale.conf" ]]; then
    pass "restore remplace la configuration"
else
    fail "restore a laissé des fichiers obsolètes"
fi

MALICIOUS_DIR="$(mktemp_dir)"
ln -s /tmp "${MALICIOUS_DIR}/outside"
tar -czf "${MALICIOUS_DIR}/malicious.tar.gz" -C "${MALICIOUS_DIR}" outside
printf 'o\n' | HOME="${TEST_HOME}" "${SSHA_BIN}" -r "${MALICIOUS_DIR}/malicious.tar.gz" >"${LOG_DIR}/restore_malicious.out" 2>&1 || true
if grep -q 'liens symboliques ne sont pas autorisés' "${LOG_DIR}/restore_malicious.out"; then
    pass "restore rejette les archives malicieuses"
else
    fail "restore accepte une archive malicieuse"
fi
rm -rf "${MALICIOUS_DIR}"

printf '0\no\n' | HOME="${TEST_HOME}" "${SSHA_BIN}" -d >"${LOG_DIR}/delete.out" 2>&1 || true
if [[ -f "${TEST_HOME}/.ssha/.deleted/0_srv1.conf" ]]; then
    pass "suppression serveur vers .deleted"
else
    fail "suppression serveur non effective"
fi

SECRET_WITHOUT_MAC="$(find "${TEST_HOME}/.ssha/.data" -type f | head -1)"
grep -v '^mac=' "${SECRET_WITHOUT_MAC}" | grep -v '^auth_type=' >"${LOG_DIR}/secret_legacy.tmp"
mv "${LOG_DIR}/secret_legacy.tmp" "${SECRET_WITHOUT_MAC}"
printf '%s\no\n' "${MASTER_PASS}" | HOME="${TEST_HOME}" "${SSHA_BIN}" -m >"${LOG_DIR}/migrate.out" 2>&1 || true
if grep -q '^mac=' "${SECRET_WITHOUT_MAC}" && grep -q '^auth_type=' "${SECRET_WITHOUT_MAC}"; then
    pass "migration remet à niveau un secret incomplet"
else
    fail "migration ne remet pas à niveau le secret incomplet"
fi
if grep -q 'Secrets remis au format durci : 1' "${LOG_DIR}/migrate.out"; then
    pass "migration journalise la remise à niveau"
else
    fail "journal de migration incomplet"
fi

printf "\n--- Résumé ---\n"
printf "PASS=%s FAIL=%s\n" "${PASS_COUNT}" "${FAIL_COUNT}"

if ((FAIL_COUNT > 0)); then
    printf "\n--- Extraits logs (échecs) ---\n"
    for log_file in "${LOG_DIR}"/*.out; do
        if grep -Eq "incorrect|Impossible de déchiffrer|Erreur|invalide|FAIL|command not found" "${log_file}"; then
            printf "\n### %s\n" "$(basename "${log_file}")"
            sed -n '1,120p' "${log_file}"
        fi
    done
    exit 1
fi
