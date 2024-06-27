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

OSSEC_CONF="/var/ossec/etc/ossec.conf"
DIRECTORIES_LINE='\t\t<directories realtime="yes" check_all="yes" report_changes="yes">/var/www/html</directories>'

OSSEC_CONFIG_BLOCK='
<ossec_config>
  <localfile>
    <location>/var/log/audit/audit.log</location>
    <log_format>audit</log_format>
  </localfile>
</ossec_config>

<ossec_config>
<localfile>
    <log_format>full_command</log_format>
    <command>ss -nputw | egrep '\''"sh"|"bash"|"csh"|"ksh"|"zsh"'\'' | awk '\''{ print $5 "|" $6 }'\''</command>
    <alias>webshell connections</alias>
    <frequency>120</frequency>
</localfile>
</ossec_config>
'

if grep -q "<directories.*>/var/www/html</directories>" "$OSSEC_CONF"; then
  echo -e "The <directories> line already exists in the <syscheck> block."
else
  awk -v new_line="$DIRECTORIES_LINE" '
    /<syscheck>/ {
      print $0
      print new_line
      next
    }
    { print $0 }
  ' "$OSSEC_CONF" > "${OSSEC_CONF}.tmp" && mv "${OSSEC_CONF}.tmp" "$OSSEC_CONF"

  echo -e "Añadida la línea <directories>... al bloque <syscheck>."
fi

if grep -q "<location>/var/log/audit/audit.log" "$OSSEC_CONF"; then
  echo -e "El bloque <ossec_config> ya existe en el archivo."
else
  echo "$OSSEC_CONFIG_BLOCK" >> "$OSSEC_CONF"
  echo -e "Añadido el bloque <ossec_config> al final del archivo."
fi

echo -e "¡Agente configurado con éxito!"