#!/bin/bash
set -e

# Set schedule config
SCHEDULE_CONFIG="${SCHEDULE_CONFIG:-$1}"

# Exit with error if BACKUP_TRIGGER_ID wasn't provided
if ! [ -f "${SCHEDULE_CONFIG}" ]; then
  echo "Could not find schedule configuration '${SCHEDULE_CONFIG}'."
  exit 1
fi

# Set the resulting cron file
CRONFILE=$(echo "/etc/cron.d/`basename ${SCHEDULE_CONFIG} | sed -En 's/\.rb$//p'`")

# Write the whenever schedule to the cron definition
printf "Creating cronfile '${CRONFILE}' from schedule '${SCHEDULE_CONFIG}'... "
pushd /opt/backups > /dev/null
bundle exec whenever --load-file "${SCHEDULE_CONFIG}" > "${CRONFILE}"
popd > /dev/null
echo "done."
