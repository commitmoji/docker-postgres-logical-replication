#!/bin/bash

cp env/.env.local mnt/home/postgres/.env
docker build . -t dbs
docker run \
	-it \
	--rm \
	-p 8001:5432 \
	--name dbs \
	dbs
rm mnt/home/postgres/.env