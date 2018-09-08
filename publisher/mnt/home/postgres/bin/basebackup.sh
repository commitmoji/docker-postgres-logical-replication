#!/usr/bin/env bash

date
echo "***** beginning basebackup.sh"

tar -cpf /mnt/efs/db/seeds/current/_tmp.tar -C /mnt/efs/db/seeds/current/basebackup . > /dev/null
rm -rf /mnt/efs/db/seeds/current/basebackup/*

pg_basebackup \
    -D /mnt/efs/db/seeds/current/basebackup \
    -Xs \
    -c fast \
    --progress \
    --label="$(date +%s)" \
    -R
EC_BACKUP=$?

if [[ ${EC_BACKUP} -ne 0 ]]
then
    echo "***** backup not successful, reverting"
    tar -xpf /mnt/efs/db/seeds/current/_tmp.tar -C /mnt/efs/db/seeds/current/basebackup > /dev/null
fi

rm -f /mnt/efs/db/seeds/current/_tmp.tar

echo "***** basebackup.sh ended"

exit ${EC_BACKUP}