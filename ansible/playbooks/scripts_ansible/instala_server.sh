#!/bin/bash

# Check if Wazuh Manager service is running
service_status=$(systemctl is-active wazuh-manager)

# Check if Wazuh Manager directory exists
wazuh_dir="/var/ossec"
dir_exists=false
if [ -d "$wazuh_dir" ]; then
    dir_exists=true
fi

# Check if Wazuh Manager executable exists
wazuh_exec="/var/ossec/bin/wazuh-control"
exec_exists=false
if [ -f "$wazuh_exec" ]; then
    exec_exists=true
fi

# Output results
if [ "$service_status" == "active" ] && [ "$dir_exists" == true ] && [ "$exec_exists" == true ]; then
    echo "Wazuh Manager is installed and running."
    exit 0
elif [ "$dir_exists" == true ] && [ "$exec_exists" == true ]; then
    echo "Wazuh Manager is installed but not running."
    exit 0
else
    echo "Wazuh Manager is not installed."
    echo "Let's do this!"

    curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh && sudo bash ./wazuh-install.sh -a -i
fi