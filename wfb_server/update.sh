#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="/usr/sbin/wfb_server"
SERVICE_DEST="/etc/systemd/system/wfb.service"

echo "Updating files in ${DEST_DIR} from ${SCRIPT_DIR}"

if [[ ! -d "${DEST_DIR}" ]];
then
    echo "Creating destination directory ${DEST_DIR}"
    mkdir -p "${DEST_DIR}"
fi

for path in "${SCRIPT_DIR}"/*; do
    [[ -f "${path}" ]] || continue
    filename="$(basename "${path}")"
    if [[ "${filename}" == "wfb_server.cfg" ]]; then
        echo "Skipping ${filename}"
        continue
    fi
    echo "Copying ${filename} to ${DEST_DIR}"
    cp -f "${path}" "${DEST_DIR}/"
done

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
