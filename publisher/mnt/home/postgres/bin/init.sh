#!/usr/bin/env bash

writeConfig() {
    echo "***** adding entries to pg_hba.conf and postgresql.auto.conf "
    echo "host     all     postgres     0.0.0.0/0     md5" >> ${PGDATA}/pg_hba.conf
    echo "host     all     app     0.0.0.0/0     md5" >> ${PGDATA}/pg_hba.conf
    echo "host all replicator 172.0.0.0/8 md5" >> ${PGDATA}/pg_hba.conf
    echo "host all replicator 10.0.0.0/16 md5" >> ${PGDATA}/pg_hba.conf
    echo "host all app_writer 172.0.0.0/8 md5" >> ${PGDATA}/pg_hba.conf
    echo "host all app_writer 10.0.0.0/16 md5" >> ${PGDATA}/pg_hba.conf
}

recycleSeeds()
{
    echo "***** recycling current directory"
    cd ${DBDIR}/seeds
    rm -f current
    ln -s ${TIMESTAMP} current
    echo "***** done recycling current directory"
}
echo "***** running /home/postgres/bin/init.sh"

#echo "***** current env:"
#env

TIMESTAMP=`date +%s`

DBDIR=/mnt/efs/db
SEEDDIR=${DBDIR}/seeds/${TIMESTAMP}
WALDIR=${SEEDDIR}/wal
BACKUPDIR=${SEEDDIR}/basebackup
CURRENT=${DBDIR}/seeds/current
echo "***** WALDIR: ${WALDIR}"
echo "***** BACKUPDIR: ${BACKUPDIR}"
mkdir ${WALDIR} -p
mkdir ${BACKUPDIR} -p
echo "***** created seed directories:"
ls -Al ${SEEDDIR}

# SHUT UP IDE!
PGDATA=${PGDATA}

mkdir ~/log

echo "***** clearing PGDATA from installed db:"
rm -rf ${PGDATA}/*

pg_ctl initdb -l ~/log/postgres

if [[ -d "${CURRENT}/basebackup" && "$(ls -A ${CURRENT}/basebackup)" ]];
then
    ## restore
    echo "***** /mnt/efs/db/seeds/current/basebackup EXISTS:"
    ls -Al ${PGDATA}
    echo "***** clearing PGDATA from initialized installed db:"
    rm -rf ${PGDATA}/*
    ls -Al ${PGDATA}
    echo "***** copying current basebackup to current PGDATA:"
    cp -ar /mnt/efs/db/seeds/current/basebackup/* ${PGDATA}/
    ls -Al ${PGDATA}
    echo "***** checking to see if wal_running is empty, if so, let basebackup's pg_wal live"
    if [ "$(ls -A ${DBDIR}/wal_running)" ]
    then
        echo "***** wal_running is not empty"
        echo "***** removing backup pg_wal from basebackup"
        rm -rf ${PGDATA}/pg_wal/*
    else
        echo "***** wal_running archive was empty"
    fi
    echo "***** taking care of recovery.conf"
    mv ${PGDATA}/recovery.conf ${PGDATA}/recovery.conf.original
    echo "standby_mode = 'off'" >> ${PGDATA}/recovery.conf
    echo "restore_command = '/home/postgres/bin/restore_command.sh %f \"%p\"'" >> ${PGDATA}/recovery.conf
    echo "recovery_end_command = '/home/postgres/bin/recovery_end_command.sh %r'" >> ${PGDATA}/recovery.conf
    echo "recovery_target_timeline = 'latest'" >> ${PGDATA}/recovery.conf
    echo "***** copying last current basebackup to current basebackup"
    cp -ar /mnt/efs/db/seeds/current/basebackup/* ${BACKUPDIR}/
    writeConfig
    recycleSeeds
    pg_ctl start -l ~/log/postgres
else
    ## no restore
    echo "***** /mnt/efs/db/seeds/current/basebackup DOES NOT EXIST"
    writeConfig
    echo "listen_addresses = '*'" >> ${PGDATA}/postgresql.auto.conf
    recycleSeeds
    pg_ctl start -l ~/log/postgres
    echo "***** creating new db"
    psql -c "alter role postgres password 'postgres';"
    echo "***** rigging logical replication and wal archiving"
    psql < ${HOME}/sql/1_logicalReplication.sql
    psql < ${HOME}/sql/2_walArchiving.sql
    psql < ${HOME}/sql/3_appDDL.sql \
        --set X_CRED_POSTGRES=${X_CRED_POSTGRES} \
        --set X_CRED_REPLICATOR=${X_CRED_REPLICATOR} \
        --set X_CRED_APP=${X_CRED_APP} \
        --set X_CRED_APP_READER=${X_CRED_APP_READER} \
        --set X_CRED_APP_WRITER=${X_CRED_APP_WRITER}
    psql < ${HOME}/sql/4_appSchemaPublication.sql
    echo "***** done creating db"
    pg_ctl restart -l ~/log/postgres
    echo "***** grabbing a basebackup"
    ~/bin/basebackup.sh
    crontab ~/.crontab_running
fi