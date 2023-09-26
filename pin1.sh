#!/usr/bin/env bash

mkdir jenkins-data/
mkdir nexus-data/
chown -R 200 nexus-data/
mkdir registry-data/

docker compose up


