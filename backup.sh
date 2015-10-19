#!/bin/bash
set -e

# Set environment variables
export BACKUP_DATA_DIR="${BACKUP_DATA_DIR:-/var/lib/backups}"
export BACKUP_CONFIG_DIR="${BACKUP_CONFIG_DIR:-/etc/backups}"
export BACKUP_TRIGGER_ID="${1:-$BACKUP_TRIGGER_ID}"

# Exit with error if BACKUP_TASK wasn't provided
if [ -z "${BACKUP_TRIGGER_ID}" ]; then
  echo >&2 "The backup task must be provided either with the BACKUP_TRIGGER_ID environment variable or the first argument."
  exit 1
fi

echo "Triggering backup ${BACKUP_TRIGGER_ID}."
pushd /home/backups > /dev/null
/usr/local/bundle/bin/backup \
  perform \
  --config-file="${BACKUP_CONFIG_DIR}/config.rb" \
  --root-path="${BACKUP_DATA_DIR}" \
  --trigger ${BACKUP_TRIGGER_ID}
popd > /dev/null
