#!/bin/bash

# Obtener el id del usuario con el que se ejecuta apache
user_id=$(apachectl -S | grep User | awk '{print $3}' | awk -F'=' '{print $2}')

# Comprueba que la variable se ha establecido correctamente
if [ -z "$user_id" ]; then
    echo "No se ha encontrado el User ID"
    exit 1
fi

# El archivo de configuración donde se añadirán las reglas
audit_file="/etc/audit/rules.d/audit.rules"

# Se definen las reglas con el user ID obtenido
audit_rules=$(cat <<EOF
## Reglas para auditd que detectan ejecución de comandos del usuario www-data
-a always,exit -F arch=b32 -S execve -F uid=${user_id} -F key=webshell_command_exec
-a always,exit -F arch=b64 -S execve -F uid=${user_id} -F key=webshell_command_exec

## Reglas para auditd que detectan conexiones de red desde el usuario www-data
-a always,exit -F arch=b64 -S socket -F a0=10 -F euid=${user_id} -k webshell_net_connect
-a always,exit -F arch=b64 -S socket -F a0=2 -F euid=${user_id} -k webshell_net_connect
-a always,exit -F arch=b32 -S socket -F a0=10 -F euid=${user_id} -k webshell_net_connect
-a always,exit -F arch=b32 -S socket -F a0=2 -F euid=${user_id} -k webshell_net_connect
EOF
)

# Se añaden las reglas al archivo
echo "$audit_rules" >> "$audit_file"

# Se indica que el resultado ha sido satisfactorio
echo "Se han añadido satisfactoriamente las reglas al archivo $audit_file"