#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_FILE="${ROOT_DIR}/ssha"
CHECKSUM_FILE="${ROOT_DIR}/ssha.sha256"

if [[ ! -f "${TARGET_FILE}" || ! -f "${CHECKSUM_FILE}" ]]; then
    echo "Fichiers requis absents (${TARGET_FILE} / ${CHECKSUM_FILE})." >&2
    exit 1
fi

EXPECTED_HASH="$(awk '{print $1}' "${CHECKSUM_FILE}")"

if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_HASH="$(sha256sum "${TARGET_FILE}" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
    ACTUAL_HASH="$(shasum -a 256 "${TARGET_FILE}" | awk '{print $1}')"
else
    echo "sha256sum ou shasum est requis." >&2
    exit 1
fi

if [[ "${EXPECTED_HASH}" != "${ACTUAL_HASH}" ]]; then
    echo "Checksum invalide." >&2
    echo "Attendu : ${EXPECTED_HASH}" >&2
    echo "Obtenu  : ${ACTUAL_HASH}" >&2
    exit 1
fi

echo "Checksum valide."
