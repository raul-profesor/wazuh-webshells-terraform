#!/bin/bash

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
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/instalar_agente_ubuntu.yml

# Check if Ansible succeeded
if [ $? -ne 0 ]; then
    echo "Ansible playbook failed"
    exit 1
fi

echo "Infrastructure provisioned and configured successfully"
