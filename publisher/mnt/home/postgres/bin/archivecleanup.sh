#!/usr/bin/env bash

echo "***** running pg_archivecleanup for $1"
pg_archivecleanup -d /mnt/efs/db/wal_running $1
#rm -rf /mnt/efs/db/wal_running/$1