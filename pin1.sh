#!/usr/bin/env bash

mkdir jenkins-data/
mkdir nexus-data/
chown -R 200:200 nexus-data/
mkdir registry-data/

docker compose up

docker stop jenkins-G4
docker stop nexus-G4
docker stop registry-G4

