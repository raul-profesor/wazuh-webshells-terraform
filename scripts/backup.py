import json
import yaml
import os

directorio_actual = os.path.dirname(os.path.abspath(__file__)) 
directorio_json = os.path.join(directorio_actual, 'salida_terraform.json')
# Load Terraform outputs
with open(directorio_json, 'r') as f:
    salida_terraform = json.load(f)


instancias_nombres_usuario = {
    "ubuntu": "ubuntu",
    "debian": "admin",
    "amazon": "ec2-user",
    "windows": "admin"
}
# Create Ansible inventory
inventory = {
    'all': {
        'hosts': {},
        'vars': {
            'ansible_ssh_common_args': '-o StrictHostKeyChecking=no',
            'private_key_file': 'despliegue_wazu.pem'
        }
    }
}

def obtener_usuario(entrada):
    for key, value in instancias_nombres_usuario.items():
        if key in entrada.lower():  # Case-insensitive comparison
            return value
    return None

# Add each instance to the inventory
#for id_instancia, ip_instancia in zip(salida_terraform['id_instancias']['value'], salida_terraform['instance_ips']['value']):
for host, ip in salida_terraform['instance_ips']['value'].items():   
    usuario_asignado = obtener_usuario(host)
        #if host.split('-')[0].lower() in instancias_nombres_usuario.items():
    #    usuario_ssh = 
    inventory['all']['hosts'][host] = {
        
        'ansible_host': ip,
        'ansible_ssh_user': usuario_asignado
        #'private_key_file': 'despliegue_wazu.pem'
        #'ansible_user': 'your_username',  # Replace with your username
        #'ansible_password': '{{ lookup("env", "ANSIBLE_PASSWORD") }}',
        #'ansible_ssh_common_args': '-o StrictHostKeyChecking=no'
    }

directorio_inventario = "."
directorio_inventario_yaml = os.path.join(directorio_inventario,'inventory.yaml')
# Write inventory to a file
with open(directorio_inventario_yaml, 'w') as f:
    yaml.dump(inventory, f, default_flow_style=False)
