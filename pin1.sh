#!/usr/bin/env bash

mkdir jenkins-data/
mkdir nexus-data/
chown -R 200:200 nexus-data/
mkdir registry-data/

docker compose up

docker stop jenkins-GRUPO4
docker stop nexus-GRUPO4
docker stop registry-GRUPO4

