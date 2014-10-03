#!/bin/sh
set -e

exec monitor-schedules.sh >> "${HOME}/schedule-updated.log" 2>&1
