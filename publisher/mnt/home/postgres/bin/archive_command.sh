#!/usr/bin/env bash

echo "***** archive_command.sh invoked ($(date)); f: ${1} p: ${2}"

if [[ -f /mnt/efs/db/seeds/current/wal/$1 || -f /mnt/efs/db/wal_running/$1 ]]
then
    echo " *****  $1 already exists"
    exit 1
else
    echo " ***** $1 does not exists, copying"
    mkdir -p /mnt/efs/db/wal_running 2>&1 >> /dev/null
    RESULT=$(cp -pn $2 /mnt/efs/db/seeds/current/wal/$1 && cp -pn $2 /mnt/efs/db/wal_running/$1)
    if [[ $? -eq 0 ]]
    then
        echo " ***** archival of ${1} WAS successful"
        exit 0
    else
        echo " ***** archival of ${1} was NOT successful"
        exit 1
    fi
fi