#!/bin/bash
set -e

# Set environment variables
export BACKUP_DATA_DIR="${BACKUP_DATA_DIR:-/data}"
export BACKUP_CONFIG_DIR="${BACKUP_CONFIG_DIR:-/etc/backups}"
export BACKUP_LOCK_WAIT=${BACKUP_LOCK_WAIT:-300}
export BACKUP_TRIGGER_ID="${BACKUP_TRIGGER_ID:-$1}"

# Exit with error if BACKUP_TASK wasn't provided
if [ -z "${BACKUP_TRIGGER_ID}" ]; then
  echo "The backup task must be provided either with the BACKUP_TRIGGER_ID environment variable or the first argument."
  exit 1
fi

echo "Triggering backup ${BACKUP_TRIGGER_ID}."
mkdir -p "${BACKUP_DATA_DIR}/.tmp"
pushd /opt/backups > /dev/null
  if [ "${BACKUP_LOCK_WAIT}" = "0" ]; then
    /usr/bin/flock --exclusive --nonblock "${BACKUP_DATA_DIR}/.tmp/trigger-backup-${BACKUP_TRIGGER_ID}.lockfile" \
      bundle exec backup perform --config-file="${BACKUP_CONFIG_DIR}/config.rb" --root-path="${BACKUP_DATA_DIR}" \
      --trigger ${BACKUP_TRIGGER_ID}
  else
    /usr/bin/flock --exclusive --wait ${BACKUP_LOCK_WAIT} "${BACKUP_DATA_DIR}/.tmp/trigger-backup-${BACKUP_TRIGGER_ID}.lockfile" \
      bundle exec backup perform --config-file="${BACKUP_CONFIG_DIR}/config.rb" --root-path="${BACKUP_DATA_DIR}" \
      --trigger ${BACKUP_TRIGGER_ID}
  fi
popd > /dev/null
