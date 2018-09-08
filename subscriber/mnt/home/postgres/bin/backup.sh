#!/usr/bin/env bash

echo "***** beginning backup.sh"

#TIMESTAMP=`date +%s`
#DBDIR=/mnt/efs/db
#WALDIR=${DBDIR}/wal
#SEEDDIR=${DBDIR}/seeds/${TIMESTAMP}
#BACKUPDIR=${SEEDDIR}/basebackup
#
#mkdir ${BACKUPDIR} -p
#
#cd ${DBDIR}/seeds
#rm -f current
#ln -s ${TIMESTAMP} current

rm -rf /mnt/efs/db/seeds/current/basebackup/*

pg_basebackup \
    -D /mnt/efs/db/seeds/current/basebackup \
    -Xs \
    -c fast \
    -R

#LATESTWALBACKUPFILE=""
#
#if [ $? -eq 0 ]; then
#    cd ${WALDIR}
#    for FILE in *.backup; do
#        [[ ${FILE} -nt ${LATESTWALBACKUPFILE} ]] && LATESTWALBACKUPFILE=${FILE}
#    done
#    echo "latest backup file: ${LATESTWALBACKUPFILE}"
#    pg_archivecleanup -d ${WALDIR} ${LATESTWALBACKUPFILE}
#fi