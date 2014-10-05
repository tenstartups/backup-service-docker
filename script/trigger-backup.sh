#!/bin/bash
set -e

# Set environment variables
export BACKUP_DATA_DIR="${BACKUP_DATA_DIR:-/data}"
export BACKUP_CONFIG_DIR="${BACKUP_CONFIG_DIR:-/etc/backups}"
export BACKUP_TRIGGER_ID="${BACKUP_TRIGGER_ID:-$1}"

# Exit with error if BACKUP_TASK wasn't provided
if [ "${BACKUP_TRIGGER_ID}" == "" ]; then
  echo "The backup task must be provided either with the BACKUP_TRIGGER_ID environment variable or the first argument."
  exit 1
fi

echo "Triggering backup ${BACKUP_TRIGGER_ID}."
mkdir -p "${BACKUP_DATA_DIR}/.tmp"
/usr/bin/flock --exclusive --wait 300 "${BACKUP_DATA_DIR}/.tmp/trigger-backup-${BACKUP_TRIGGER_ID}.lockfile" \
  bundle exec backup perform --config-file="${BACKUP_CONFIG_DIR}/config.rb" --root-path="${BACKUP_DATA_DIR}" \
  --trigger ${BACKUP_TRIGGER_ID}
