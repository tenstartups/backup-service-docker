#!/bin/sh
set -e

# Set environment
PATTERN='.*\.rb$'
COMMAND='create-schedule'

# Load from existing schedules
mkdir -p "${BACKUP_CONFIG_DIR}/schedules"
echo "Loading existing schedules..."
find "${BACKUP_CONFIG_DIR}/schedules" -regex "${PATTERN}" -exec sh -c "\"${COMMAND}\" \"{}\"" \;

# Monitor for new schedules
echo "Monitoring for new or changed schedules..."
inotifywait -q -m -e create -e modify "${BACKUP_CONFIG_DIR}/schedules" | \
  grep -E --line-buffered -e "${PATTERN}" | \
  while read path action file; do
    echo "[$(date -Is)] ${file}"
    "${COMMAND}" "${BACKUP_CONFIG_DIR}/schedules/${file}"
  done
