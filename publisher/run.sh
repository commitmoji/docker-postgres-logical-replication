#!/bin/bash

cp env/.env.local mnt/home/postgres/.env
docker build . -t dbp
docker run \
	-it \
	--rm \
	-p 8000:5432 \
	--name dbp \
	--mount type=bind,source=`pwd`/mnt/efs/db,destination=/mnt/efs/db \
	--privileged \
	dbp
rm mnt/home/postgres/.env
