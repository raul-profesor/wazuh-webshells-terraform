## ¿Qué necesito para desplegar el escenario?

1. Terraform, Ansible y AWS CLI instalados en tu máquina.

2. Estar inscrito en un Learner Lab en AWS.

## ¿Cómo despliego?

En primer lugar, hace falta configurar las credenciales para poder acceder a AWS mediante CLI. Para ello hacen falta 3 elementos:

1. aws_access_key_id
2. aws_secret_access_key
3. aws_session_token

Y estos 3 valores deben configurarse en `~/.aws/credentials`

Dar permisos de ejecución al script:

```
chmod u+x crea_escenario.sh
```

Y ejecutarlo:

```
./crea_escenario.sh
```

Y comenzará el despliegue:

+ Comprobará que el módulo pywinrm está instalado en el sistema para poder conectarse mediante Winrm a la instancia Windows
+ Desplegará la infraestructura con Terraform
+ Generará un inventario que contendrá las IPs de las instancias y todo lo necesario para que sea utilizdo por Ansible
+ Realizará la provisión y configuración de instancias haciendo uso de Ansible

Se debe tener paciencia puesto que el proceso puede tardar ~15 minutos.

## Tras el despliegue, como llevo a cabo la comprobación del escenario

Una vez desplegado el escenario, para conectarse a cualquier instancia Linux:

```
ssh -i despliegue_wazuh.pem usuario@x.x.x.x
```

### Poner a la escucha netcat en la máquina Debian

Para esto nos conectamos por ssh a ella e instalamos netcat:

```
sudo apt update && sudo apt install netcat-traditional
```

Lo ponemos a la escucha en el puerto 4444:

```
nc -nvlp 4444
```

Y ejecutamos ambas webshells.



