data "aws_vpc" "default" {
  default = true
}

# Datos pra generar par de claves
resource "tls_private_key" "wazuh_lab_cecib" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Crear par de claves
resource "aws_key_pair" "despliegue" {
  key_name   = "wazuh-lab-key"
  public_key = tls_private_key.wazuh_lab_cecib.public_key_openssh
}

resource "local_file" "clave_privada" {
  content  = tls_private_key.wazuh_lab_cecib.private_key_pem
  filename = "${path.module}/despliegue_wazuh.pem"
  file_permission = "0400" 
}

/*resource "aws_security_group" "ubuntu_agente_sg" {
  name_prefix = "ubuntu-agente-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block] # Allow all TCP traffic from the private network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "debian_atacante_sg" {
  name_prefix = "debian-atacante-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]  # Allow all TCP traffic from the private network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wazuh_server_sg" {
  name_prefix = "wazuh-server-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS access from anywhere
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]  # Allow all TCP traffic from the private network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "windows_agente_sg" {
  name_prefix = "windows-agente-sg"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # RDP access from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]  # Allow all TCP traffic from the private network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}*/

/*resource "aws_instance" "ubuntu_instance" {
  ami             = "ami-04b70fa74e45c3917"  # Replace with the correct Ubuntu AMI ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ubuntu_agente_sg.name]
  key_name        = aws_key_pair.despliegue.key_name

  tags = {
    Name = "Ubuntu-Agente"
  }
}

resource "aws_instance" "debian_instance" {
  ami             = "ami-058bd2d568351da34"  # Replace with the correct Debian AMI ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.debian_atacante_sg.name]
  key_name        = aws_key_pair.despliegue.key_name

  tags = {
    Name = "Debian-Atacante"
  }
}

resource "aws_instance" "amazon_linux_instance" {
  ami             = "ami-0d94353f7bad10668"  # Replace with the correct Amazon Linux 2 AMI ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.wazuh_server_sg.name]
  key_name        = aws_key_pair.despliegue.key_name

  tags = {
    Name = "Wazuh-Server"
  }
}

resource "aws_instance" "windows_instance" {
  ami             = "ami-02dca614f074272a6"  # Replace with the correct Windows Server 2022 AMI ID
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.windows_agente_sg.name]

  tags = {
    Name = "Windows-Agente"
  }
}*/

resource "aws_security_group" "instancia_sg" {
  for_each = var.instancias

  name        = "${each.key}_sg"
  description = "Security group for ${each.key}"

  dynamic "ingress" {
    for_each = each.value.security_group_reglas
    content {
      #description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [for cidr in ingress.value.cidr_blocks : cidr == "vpc_cidr_block" ? data.aws_vpc.default.cidr_block : cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  for_each = var.instancias

  ami             = each.value.ami
  instance_type   = each.value.instance_type
  key_name        = aws_key_pair.despliegue.key_name
  security_groups = [aws_security_group.instancia_sg[each.key].name]
  tags = {
    Name = each.key
  }
}

output "default_vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
}

output "instance_ips" {
  value = { for k, v in aws_instance.this : k => v.public_ip }
}



