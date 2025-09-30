#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="/usr/sbin/wfb_server"
SERVICE_DEST="/etc/systemd/system/wfb.service"

echo "Updating files in ${DEST_DIR} from ${SCRIPT_DIR}"

if [[ -d "${DEST_DIR}" ]]; then
    TIMESTAMP="$(date +%Y%m%d%H%M%S)"
    BACKUP_DIR="${DEST_DIR}/backup_${TIMESTAMP}"
    echo "Creating backup in ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
    shopt -s dotglob
    for existing in "${DEST_DIR}"/*; do
        [[ -e "${existing}" ]] || continue
        if [[ "${existing}" == "${BACKUP_DIR}" ]]; then
            continue
        fi
        name="$(basename "${existing}")"
        if [[ "${name}" == backup_* ]]; then
            echo "Skipping existing backup ${name}"
            continue
        fi
        echo "Backing up ${name}"
        cp -a "${existing}" "${BACKUP_DIR}/"
    done
    shopt -u dotglob
else
    echo "Creating destination directory ${DEST_DIR}"
    mkdir -p "${DEST_DIR}"
fi

shopt -s dotglob
for path in "${SCRIPT_DIR}"/*; do
    [[ -e "${path}" ]] || continue
    filename="$(basename "${path}")"
    if [[ "${filename}" == "wfb_server.cfg" ]]; then
        echo "Skipping ${filename}"
        continue
    fi
    echo "Copying ${filename} to ${DEST_DIR}"
    cp -a "${path}" "${DEST_DIR}/"
done
shopt -u dotglob

if [[ ! -f "${SCRIPT_DIR}/wfb.service" ]]; then
    echo "Service file wfb.service not found in ${SCRIPT_DIR}" >&2
    exit 1
fi

echo "Updating systemd service at ${SERVICE_DEST}"
cp -f "${SCRIPT_DIR}/wfb.service" "${SERVICE_DEST}"

echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Restarting wfb service"
systemctl restart wfb

echo "Update complete"
