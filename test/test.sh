#!/usr/bin/env bash

mkdir -p opt/tubearchivist
cd opt/tubearchivist

TA_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
ELASTIC_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)

echo "TA_HOST=http://tubearchivist:8000" >> .env
echo "TA_PASSWORD=${TA_PASSWORD}" >> .env
echo "ELASTIC_PASSWORD=${ELASTIC_PASSWORD}" >> .env
echo "TZ=Europe/Berlin" >> .env

if ! curl -fsSL "https://raw.githubusercontent.com/tubearchivist/tubearchivist/refs/heads/master/docker-compose.yml" -o "docker-compose.yml"; then
  exit 1
fi
