#!/usr/bin/env bash

echo "***** restore_command: f: $1, p: $2"
test -f /mnt/efs/db/wal_running/$1 && cp /mnt/efs/db/wal_running/$1 ${PGDATA}/$2