#!/bin/bash

if python -c "import winrm" &> /dev/null; then
    echo 'Ya tenías pywinrm instalado'
else
    echo 'Vamos a instalar python-winrm'
    pip3 install pywinrm
fi

# Step 1: Run Terraform to create infrastructure

terraform init
terraform apply -auto-approve
#terraform plan
# Step 2: Generate Terraform output in JSON format

# Check if Terraform succeeded
if [ $? -ne 0 ]; then
    echo "Terraform apply failed"
    exit 1
fi

terraform output -json > ./scripts/salida_terraform.json

# Step 3: Run the Python script to generate the Ansible inventory
python3 ./scripts/genera_inventario.py

# Step 4: Run the Ansible playbook using the generated inventory
# Run Ansible
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/instalar_apache.yml
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/configurar_servidor_wazuh.yml
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/instalar_agente_ubuntu.yml
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/configurar_agente_ubuntu.yml
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/instalar_agente_windows.yml
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/instalar_IIS.yml





# Check if Ansible succeeded
if [ $? -ne 0 ]; then
    echo "Ansible playbook failed"
    exit 1
fi

echo "Infrastructura desplegada y provisionada con éxito"