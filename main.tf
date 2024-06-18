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
  user_data = each.value.is_windows ? <<-EOF
    <powershell>
    # Create a new listener
    winrm create winrm/config/Listener?Address=*+Transport=HTTPS

    # Set the winrm service to start automatically
    Set-Service -Name winrm -StartupType Automatic

    # Allow basic authentication for winrm
    winrm set winrm/config/service/Auth @{Basic="true"}

    # Allow unencrypted communication for winrm
    winrm set winrm/config/service @{AllowUnencrypted="true"}

    # Create self-signed certificate
    $cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My

    # Create HTTPS listener with the certificate
    winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="$env:COMPUTERNAME";CertificateThumbprint="$($cert.Thumbprint)"}

    # Set winrm service configuration
    winrm set winrm/config/client @{TrustedHosts="*"}

    # Enable firewall rule for WinRM
    New-NetFirewallRule -DisplayName "WinRM-HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986

    # Open port 5986 for WinRM
    netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow
    </powershell>
    EOF : null
}

output "default_vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
}

output "instance_ips" {
  value = {
    for k, v in aws_instance.this :
    k => {
      public_ip  = v.public_ip
      private_ip = v.private_ip
    }
  }
}


