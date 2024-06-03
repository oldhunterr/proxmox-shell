#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   _____
  / ___/____  ____  ____  __________
  \__ \/ __ \/ __ \/ __ `/ ___/ ___/
 ___/ / /_/ / / / / /_/ / /  / /
/____/\____/_/ /_/\__,_/_/  /_/

    ____            __               
   / __ \____ _____/ /___  __________
  / /_/ / __ `/ __  / __ `/ ___/ ___/
 / _, _/ /_/ / /_/ / /_/ / /  / /    
/_/ |_|\__,_/\__,_/\__,_/_/  /_/     
               
EOF
}
header_info
echo -e "Loading..."
APP="Sonarr and Radarr"
var_disk="8"
var_cpu="4"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function install_sonarr() {
  msg_info "Installing Sonarr"
  wget -q -O - https://apt.sonarr.tv/pub.key | apt-key add -
  echo "deb https://apt.sonarr.tv/debian buster main" | tee /etc/apt/sources.list.d/sonarr.list
  apt update
  apt install nzbdrone -y
  systemctl enable sonarr
  systemctl start sonarr
  msg_ok "Sonarr Installed"
}

function install_radarr() {
  msg_info "Installing Radarr"
  wget -q -O - https://apt.sonarr.tv/pub.key | apt-key add -
  echo "deb https://apt.sonarr.tv/ubuntu bionic main" | tee /etc/apt/sources.list.d/radarr.list
  apt update
  apt install radarr -y
  systemctl enable radarr
  systemctl start radarr
  msg_ok "Radarr Installed"
}

function update_sonarr() {
  header_info
  if [[ ! -d /opt/Sonarr ]]; then msg_error "No Sonarr Installation Found!"; exit; fi
  msg_info "Updating Sonarr v4"
  systemctl stop sonarr.service
  wget -q -O SonarrV4.tar.gz 'https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64'
  tar -xzf SonarrV4.tar.gz
  rm -rf /opt/Sonarr
  mv Sonarr /opt
  rm -rf SonarrV4.tar.gz
  systemctl start sonarr.service
  msg_ok "Updated Sonarr v4"
  exit
}

function update_radarr() {
  header_info
  if [[ ! -d /var/lib/radarr/ ]]; then msg_error "No Radarr Installation Found!"; exit; fi
  msg_info "Updating Radarr LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated Radarr LXC"
  exit
}

start
build_container
description

msg_info "Starting Installation of Sonarr and Radarr"
install_sonarr
install_radarr

msg_ok "Completed Successfully!\n"
echo -e "Sonarr should be reachable by going to the following URL:
         ${BL}http://${IP}:8989${CL} \n"
echo -e "Radarr should be reachable by going to the following URL:
         ${BL}http://${IP}:7878${CL} \n"
