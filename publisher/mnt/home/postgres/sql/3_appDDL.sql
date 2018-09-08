--@formatter:off
--------------------------------------------------------------------------------
\c postgres postgres
ALTER ROLE postgres PASSWORD :'X_CRED_POSTGRES';
DROP ROLE IF EXISTS replicator;
CREATE ROLE replicator REPLICATION LOGIN PASSWORD :'X_CRED_REPLICATOR';

SELECT EXISTS(SELECT 1 FROM pg_user where usename = 'app') AS app_exists
\gset

\if :app_exists
\c app postgres
  DROP TABLE IF EXISTS app.population;
  DROP TABLE IF EXISTS app.client;
  DROP EXTENSION "uuid-ossp";
  DROP SCHEMA IF EXISTS app;
\endif
--------------------------------------------------------------------------------
\c postgres postgres
DROP DATABASE IF EXISTS app;
DROP ROLE IF EXISTS app;
DROP ROLE IF EXISTS app_reader;
DROP ROLE IF EXISTS app_writer;
CREATE ROLE app LOGIN PASSWORD :'X_CRED_APP' CREATEDB;
CREATE DATABASE app OWNER app;
CREATE ROLE app_reader LOGIN PASSWORD :'X_CRED_APP_READER';
ALTER ROLE app_reader SET search_path TO app, public;
CREATE ROLE app_writer LOGIN PASSWORD :'X_CRED_APP_WRITER';
ALTER ROLE app_writer SET search_path TO app, public;
--@formatter:oncd ..

--------------------------------------------------------------------------------
\c app app
CREATE SCHEMA APP;
--------------------------------------------------------------------------------
\c app postgres
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA APP;
--------------------------------------------------------------------------------
GRANT USAGE ON SCHEMA APP TO APP_READER;
--GRANT SELECT ON ALL TABLES IN SCHEMA APP TO APP_READER;
-- tha fuck?
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA APP TO APP_READER;

GRANT USAGE ON SCHEMA APP TO APP_WRITER;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA APP TO APP_WRITER;

--------------------------------------------------------------------------------