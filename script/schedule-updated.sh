#!/bin/sh
set -e

exec /opt/backups/script/monitor-schedules.sh >> "${HOME}/schedule-updated.log" 2>&1
