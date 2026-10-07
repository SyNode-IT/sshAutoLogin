#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_FILE="${ROOT_DIR}/ssha"
CHECKSUM_FILE="${ROOT_DIR}/ssha.sha256"

if [[ ! -f "${TARGET_FILE}" ]]; then
    echo "ssha introuvable: ${TARGET_FILE}" >&2
    exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${TARGET_FILE}" >"${CHECKSUM_FILE}"
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${TARGET_FILE}" >"${CHECKSUM_FILE}"
else
    echo "sha256sum ou shasum est requis." >&2
    exit 1
fi

echo "Checksum mis à jour: ${CHECKSUM_FILE}"
