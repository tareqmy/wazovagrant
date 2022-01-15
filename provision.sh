#!/bin/bash
# Will install Wazo localy
set -xe

BRANCH=wazo-$(curl https://mirror.wazo.community/version/stable)
DISTRIBUTION=pelican-buster
HOST_IP=192.168.0.183

# Requirements
# coreutils = tee
sudo apt-get update
sudo apt-get install -yq sudo git ansible curl coreutils mlocate netcat nmap strace tmux tree vim-nox wget

# Enforce valid locale
echo en_US.UTF-8 UTF-8 | sudo tee /etc/locale.gen
echo LANG=en_US.UTF-8 | sudo tee /etc/default/locale
sudo locale-gen

# Get Wazo's playbooks and their requirements
git clone https://github.com/wazo-platform/wazo-ansible.git
cd wazo-ansible
git checkout "$BRANCH"
ansible-galaxy install -r requirements-postgresql.yml

# Configuration
sed -i "s;^localhost ansible_connection=local;$HOST_IP ansible_connection=local;" inventories/uc-engine
sed -i 's;^# \[uc_ui:children\];[uc_ui:children];' inventories/uc-engine
sed -i 's;^# uc_engine_host;uc_engine_host;' inventories/uc-engine
echo "wazo_distribution = $DISTRIBUTION" >> inventories/uc-engine
echo "wazo_distribution_upgrade = $DISTRIBUTION" >> inventories/uc-engine
echo "engine_api_configure_wizard = true" >> inventories/uc-engine
echo "engine_api_root_password = wazo" >> inventories/uc-engine
echo "api_client_name = wazo" >> inventories/uc-engine
echo "api_client_password = wazo" >> inventories/uc-engine
echo "postgresql_superuser_password = wazo" >> inventories/uc-engine

# Install Wazo
ansible-playbook -i inventories/uc-engine uc-engine.yml