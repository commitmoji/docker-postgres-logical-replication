#!/usr/bin/env bash

echo "***** running /home/postgres/bin/init.sh"

slug=`echo $RANDOM | md5sum`
slug=${slug:0:6}

echo "***** slug: $slug"

echo "$X_PUBLISHER:5432:*:replicator:${X_CRED_REPLICATOR}" >> ~/.pgpass
echo "$X_PUBLISHER:5432:*:postgres:${X_CRED_POSTGRES}" >> ~/.pgpass
chmod 600 ~/.pgpass

rm -rf ${PGDATA}

pg_ctl initdb -l ~/logfile

echo "***** adding entries to pg_hba.conf and postgresql.auto.conf "
echo "host     all     postgres     0.0.0.0/0     md5" >> ${PGDATA}/pg_hba.conf
echo "host     all     app     0.0.0.0/0     md5" >> ${PGDATA}/pg_hba.conf
echo "host all app_reader 10.0.0.0/16 md5" >> ${PGDATA}/pg_hba.conf
echo "host all app_reader 10.0.0.0/16 md5" >> ${PGDATA}/pg_hba.conf
echo "host all app_reader 0.0.0.0/0 md5" >> ${PGDATA}/pg_hba.conf
echo "listen_addresses = '*'"> ${PGDATA}/postgresql.auto.conf
echo "***** about to start"

pg_ctl start -l ~/logfile

echo "***** about to run pg_dumpall"
pg_dumpall -h $X_PUBLISHER -U postgres -s | psql
echo "***** pg_dumpall completed"
echo "GRANT SELECT ON ALL TABLES IN SCHEMA APP TO APP_READER" | psql -U postgres -d app
echo "GRANT USAGE ON SCHEMA APP TO APP_reader" | psql -U postgres -d app
echo "ALTER ROLE app_reader SET search_path TO app, public" | psql -U postgres

echo "***** about to create subscription"
echo "CREATE SUBSCRIPTION allTablesSub_$slug
  CONNECTION 'dbname=app host=$X_PUBLISHER user=postgres'
  PUBLICATION allTables
 WITH (CREATE_SLOT = TRUE);" | psql -d app
echo "***** subscription created"

echo "***** init.sh completed"