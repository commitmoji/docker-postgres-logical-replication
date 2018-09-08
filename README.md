# About

Postgres is easy to run in a container, but what about persisting the data files?  This composition handles WAL archiving for PITR, and exposes logical replication.

```bash
cd docker-compose
./run.sh
```