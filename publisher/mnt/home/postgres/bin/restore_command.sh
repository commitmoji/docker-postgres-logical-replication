#!/usr/bin/env bash

echo "***** restore_command invoked: f: $1, p: $2"
if [[ -f /mnt/efs/db/wal_running/$1 ]]
then
    echo " ***** $1 DOES exist"
    cp /mnt/efs/db/wal_running/$1 ${PGDATA}/"$2"
    exit $?
else
    echo " ***** $1 does NOT exist"
    exit 1
fi