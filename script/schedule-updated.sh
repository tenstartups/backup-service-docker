#!/bin/sh
set -e

exec /opt/bin/monitor-schedules.sh >> "${HOME}/schedule-updated.log" 2>&1
