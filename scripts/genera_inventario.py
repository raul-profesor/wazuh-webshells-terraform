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
    "windows": "AdminUser"
}
# Create Ansible inventory
inventory = {
    'all': {
        'hosts': {},
        'vars': {
            'ansible_ssh_common_args': '-o StrictHostKeyChecking=no',
            'ansible_private_key_file': './despliegue_wazuh.pem'
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
for host, ips in salida_terraform['instance_ips']['value'].items():   
    public_ip = ips['public_ip']
    private_ip = ips['private_ip']
    usuario_asignado = obtener_usuario(host)
        #if host.split('-')[0].lower() in instancias_nombres_usuario.items():
    #    usuario_ssh = 
    host_vars = {
        'ansible_host': public_ip,
        'ansible_user': usuario_asignado,
        'private_ip': private_ip
    }
    
    # Check if the instance is a Windows instance
    if 'windows' in host.lower():
        host_vars.update({
            'ansible_connection': 'winrm',
            'ansible_winrm_server_cert_validation': 'ignore',
            'ansible_winrm_transport': 'basic',
            'ansible_winrm_port': 5986,
            #'ansible_user': usuario_asignado,
            'ansible_password': 'SecureP@ssword123'  # Replace with your actual password or use a secret manager
        })
    
    inventory['all']['hosts'][host] = host_vars
    # Set Ubuntu IP as an environment variable
   # if 'ubuntu' in host.lower():
    #    os.environ['IP_SERVER'] = ip

directorio_inventario = "./ansible"
directorio_inventario_yaml = os.path.join(directorio_inventario,'inventory.yaml')
# Write inventory to a file
with open(directorio_inventario_yaml, 'w') as f:
    yaml.dump(inventory, f, default_flow_style=False)
