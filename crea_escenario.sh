#!/bin/bash
# Comprobar si el módulo pywinrm está instalado
if pip show pywinrm &> /dev/null; then
    echo "El módulo pywinrm ya está instalado"
else
    echo "El móduylo pywinrm no está instalado, instalado ahora..."
    pip3 install pywinrm
    if [ $? -eq 0 ]; then
        echo "El módulo pywinrm se ha instalado con éxito."
    else
        echo "La instalación del módulo pywinrm ha fallado."
        exit 1
    fi
fi
# Crear infraestructura con terraform
terraform init
terraform apply -auto-approve

# Comprobar si terraform se ha ejecutado con éxito
if [ $? -ne 0 ]; then
    echo "Terraform ha fallado"
    exit 1
fi

terraform output -json > ./scripts/salida_terraform.json

python3 ./scripts/genera_inventario.py

ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbooks/master.yml

# Comprobar si ansible se ha ejecutado correctamente
if [ $? -ne 0 ]; then
    echo "Ansible ha fallado"
    exit 1
fi

echo "Infrastructura desplegada y provisionada con éxito."