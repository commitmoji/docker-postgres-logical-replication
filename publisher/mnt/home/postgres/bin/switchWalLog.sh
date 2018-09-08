#!/usr/bin/env bash

psql -c "select pg_switch_wal();"