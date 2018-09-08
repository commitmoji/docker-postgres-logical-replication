#!/usr/bin/env bash

test -f /mnt/efs/db/seeds/current/wal/$1

EXISTS=$?

if [ ${EXISTS} -eq 0 ]
then
    echo "***** archive_command.sh: $1 already exists"
    exit 1
else
    echo "***** archive_command.sh: $1 does not exists, copying"
    cp -i $2 /mnt/efs/db/seeds/current/wal/$1
    cp -ar $2 /mnt/efs/db/wal_running/$1
    exit 0
fi