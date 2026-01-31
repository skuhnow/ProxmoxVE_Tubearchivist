#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: YourUsername
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/application/repo

# Load all available functions (from core.func + tools.func)
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Setup Docker Repository"
setup_deb822_repo \
  "docker" \
  "https://download.docker.com/linux/$(get_os_info id)/gpg" \
  "https://download.docker.com/linux/$(get_os_info id)" \
  "$(get_os_info codename)" \
  "stable" \
  "$(dpkg --print-architecture)"
msg_ok "Setup Docker Repository"

msg_info "Installing Docker"
$STD apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
msg_ok "Installed Docker"

mkdir -p /opt/tubearchivist
cd /opt/tubearchivist

TA_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
ELASTIC_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)

echo "TA_HOST=http://tubearchivist:8000" >> .env
echo "TA_PASSWORD=${TA_PASSWORD}" >> .env
echo "ELASTIC_PASSWORD=${ELASTIC_PASSWORD}" >> .env
echo "TZ=Europe/Berlin" >> .env

if ! curl -fsSL "https://raw.githubusercontent.com/tubearchivist/tubearchivist/refs/heads/master/docker-compose.yml" -o "/opt/tubearchivist/docker-compose.yml"; then
  msg_error "Download failed"
  exit 1
fi

TA_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
ELASTIC_PASSWORD=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)

mkdir -p /opt/tubearchivist/media
sed -i "s/- media:/youtube/- ./media:/youtube" docker_compose.yml

msg_info "Initialize Tubearchivist"
$STD docker compose --env-file /opt/tubearchivist/.env up -d
msg_ok "Initialized Tubearchivist"
