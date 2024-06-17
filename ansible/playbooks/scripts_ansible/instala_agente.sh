#!/bin/bash

# Check if Wazuh agent is already installed
if dpkg -l | grep -q '^hi.*wazuh-agent'; then
    echo "Wazuh agent is already installed and on hold. Skipping installation."
    exit 0  # Exit successfully
elif dpkg -l | grep -q '^ii.*wazuh-agent'; then
    echo "Wazuh agent is already installed. Skipping installation."
    exit 0  # Exit successfully
fi


apt-get update

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update

WAZUH_MANAGER="`cat /tmp/ip_server.txt`" apt-get install wazuh-agent -y

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
apt-get update

echo "wazuh-agent hold" | dpkg --set-selections