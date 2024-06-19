instancias = {
  "Ubuntu-Agente" = {
    instance_type = "t2.micro"
    ami           = "ami-04b70fa74e45c3917"
    is_windows    = false
    security_group_reglas = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
      },
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["vpc_cidr_block"] # Allow all TCP traffic from the private network
      }
    ]
  },
  "Debian-Atacante" = {
    instance_type = "t2.micro"
    ami           = "ami-058bd2d568351da34"
    is_windows    = false
    security_group_reglas = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
      },
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["vpc_cidr_block"]  # Allow all TCP traffic from the private network
      }
    ]
  },
  "Amazon-Wazuh-Server" = {
    instance_type = "t2.medium"
    ami           = "ami-0d94353f7bad10668"
    is_windows    = false
    security_group_reglas =  [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # HTTPS access from anywhere
      },
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["vpc_cidr_block"]  # Allow all TCP traffic from the private network
      }
    ]
  },
   "Windows-Agente" = {
    instance_type = "t2.medium"
    ami           = "ami-04df9ee4d3dfde202"
    is_windows    = true
    security_group_reglas = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # RDP access from anywhere
      },
      {
        from_port   = 5986
        to_port     = 5986
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # WinRM access 
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
      },
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["vpc_cidr_block"]  # Allow all TCP traffic from the private network
      }  
    ]
  }
}

