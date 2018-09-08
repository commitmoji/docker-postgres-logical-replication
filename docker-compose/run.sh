#!/usr/bin/env bash

rm -rf ../publisher/mnt/efs/db/*

cp ../publisher/env/.env.compose ../publisher/mnt/home/postgres/.env
cp ../subscriber/env/.env.compose ../subscriber/mnt/home/postgres/.env

docker-compose build
docker-compose up
docker-compose down

rm ../publisher/mnt/home/postgres/.env
rm ../subscriber/mnt/home/postgres/.env