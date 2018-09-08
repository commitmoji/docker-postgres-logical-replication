#!/usr/bin/env bash

TIMESTAMP=`date +%s`

echo "***** recovery_end_command.sh invoked; r: ${1}"

echo "***** grabbing a basebackup in 5 seconds"
date
sleep 5
date
~/bin/basebackup.sh
EC_BACKUP=$?

mkdir -p /mnt/efs/db/wal_running_bu
tar -cvpf /mnt/efs/db/wal_running_bu/${TIMESTAMP}.tar -C /mnt/efs/db/wal_running .
EC_TAR=$?

if [[ ${EC_BACKUP} -eq 0 && ${EC_TAR} -eq 0 ]]
then
    echo "***** tar of /mnt/efs/db/wal_running succeeded, invoking pg_archivecleanup on ${1}"
    pg_archivecleanup /mnt/efs/db/wal_running ${1}
    echo "***** pg_archivecleanup completed"
else
    echo "***** backup of wal_running or tar WAS NOT SUCCESSFUL"
fi

echo "***** scheduling basebackup 5 minute from now, and then for .crontab_running to take over"
date -d "+1 minutes" +"%M %H * * * . /home/postgres/.profile && ~/bin/basebackup.sh 2>&1 >> ~/log/basebackup && crontab ~/.crontab_running" > ~/.crontab
crontab ~/.crontab

echo "***** recovery_end_command.sh completed"