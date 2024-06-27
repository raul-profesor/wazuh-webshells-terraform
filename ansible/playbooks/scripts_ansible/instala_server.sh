#!/bin/bash

# Se hacen comprobaciones previas para comprobar si wazuh-manager ya está instalado
service_status=$(systemctl is-active wazuh-manager)

wazuh_dir="/var/ossec"
dir_exists=false
if [ -d "$wazuh_dir" ]; then
    dir_exists=true
fi

wazuh_exec="/var/ossec/bin/wazuh-control"
exec_exists=false
if [ -f "$wazuh_exec" ]; then
    exec_exists=true
fi

if [ "$service_status" == "active" ] && [ "$dir_exists" == true ] && [ "$exec_exists" == true ]; then
    echo "Wazuh Manager está instalado y corriendo."
    exit 0
elif [ "$dir_exists" == true ] && [ "$exec_exists" == true ]; then
    echo "Wazuh Manager está instalado pero no corriendo."
    exit 0
else
    echo "Wazuh Manager no está instalado."
    echo "¡Vamos a ello!"

    curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
fi