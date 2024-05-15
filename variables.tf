variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "access_key_prod" {
  type = string
}

variable "secret_access_key_prod" {
  type = string
}

variable "ingress_ports" {
  type = list(object({
    ports =  number
    source = string
    description = string

  })
  )
}
