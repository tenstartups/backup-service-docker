#!/bin/sh
set -e

exec monitor-schedules >> "${HOME}/schedule-updated.log" 2>&1
