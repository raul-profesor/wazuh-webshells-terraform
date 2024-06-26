#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

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

# Define the file path
OSSEC_CONF="/home/raul/Documentos/Clases/Severo Ochoa 23-24/Documentación/borrar/ossec.conf"

# Define the new <directories> line to be added within the <syscheck> block
DIRECTORIES_LINE='\t\t<directories realtime="yes" check_all="yes" report_changes="yes">/var/www/html</directories>'

# Define the <ossec_config> block to be added at the end of the file
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

# Check if the <directories> line already exists within the <syscheck> block
if grep -q "<directories.*>/var/www/html</directories>" "$OSSEC_CONF"; then
  echo -e "${YELLOW}The <directories> line already exists in the <syscheck> block.${NC}"
else
  # Insert the <directories> line within the <syscheck> block
  awk -v new_line="$DIRECTORIES_LINE" '
    /<syscheck>/ {
      print $0
      print new_line
      next
    }
    { print $0 }
  ' "$OSSEC_CONF" > "${OSSEC_CONF}.tmp" && mv "${OSSEC_CONF}.tmp" "$OSSEC_CONF"

  echo -e "${GREEN}Added the <directories> line to the <syscheck> block.${NC}"
fi

# Check if the <ossec_config> block already exists at the end of the file
if grep -q "<location>/var/log/audit/audit.log" "$OSSEC_CONF"; then
  echo -e "${YELLOW}The <ossec_config> block already exists at the end of the file.${NC}"
else
  # Add the <ossec_config> block at the end of the file
  echo "$OSSEC_CONFIG_BLOCK" >> "$OSSEC_CONF"
  echo -e "${GREEN}Added the <ossec_config> block to the end of the file.${NC}"
fi

echo -e "${GREEN}Configuration updates completed.${NC}"
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define the file path
OSSEC_CONF="/home/raul/Documentos/Clases/Severo Ochoa 23-24/Documentación/borrar/ossec.conf"

# Define the new <directories> line to be added within the <syscheck> block
DIRECTORIES_LINE='\t\t<directories realtime="yes" check_all="yes" report_changes="yes">/var/www/html</directories>'

# Define the <ossec_config> block to be added at the end of the file
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

# Check if the <directories> line already exists within the <syscheck> block
if grep -q "<directories.*>/var/www/html</directories>" "$OSSEC_CONF"; then
  echo -e "${YELLOW}The <directories> line already exists in the <syscheck> block.${NC}"
else
  # Insert the <directories> line within the <syscheck> block
  awk -v new_line="$DIRECTORIES_LINE" '
    /<syscheck>/ {
      print $0
      print new_line
      next
    }
    { print $0 }
  ' "$OSSEC_CONF" > "${OSSEC_CONF}.tmp" && mv "${OSSEC_CONF}.tmp" "$OSSEC_CONF"

  echo -e "${GREEN}Added the <directories> line to the <syscheck> block.${NC}"
fi

# Check if the <ossec_config> block already exists at the end of the file
if grep -q "<location>/var/log/audit/audit.log" "$OSSEC_CONF"; then
  echo -e "${YELLOW}The <ossec_config> block already exists at the end of the file.${NC}"
else
  # Add the <ossec_config> block at the end of the file
  echo "$OSSEC_CONFIG_BLOCK" >> "$OSSEC_CONF"
  echo -e "${GREEN}Added the <ossec_config> block to the end of the file.${NC}"
fi

echo -e "${GREEN}Configuration updates completed.${NC}"
