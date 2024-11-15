#!/bin/bash

# Comprobar si el agente de Wazuh está ya instalado
if dpkg -l | grep -q '^hi.*wazuh-agent'; then
    echo "Wazuh agent ya está intalado y en espera. Se omite la instalación."
    exit 0  
elif dpkg -l | grep -q '^ii.*wazuh-agent'; then
    echo "Wazuh agent ya está instalado. Se omite la instalación."
    exit 0  
fi


apt-get update

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update

WAZUH_MANAGER="`cat /tmp/ip_server.txt`" apt-get install wazuh-agent=4.7.5-1 -y

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
apt-get update

echo "wazuh-agent hold" | dpkg --set-selections