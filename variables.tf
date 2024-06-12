variable "instancias" {
  type = map(object({
    instance_type = string
    ami           = string
    security_group_reglas = list(object({
      #description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  default = {}
}

