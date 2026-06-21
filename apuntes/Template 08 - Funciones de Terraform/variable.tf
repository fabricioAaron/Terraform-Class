variable "proyecto_name" {
  type        = string
  description = "nombre del proyecto"
  default     = "Project ALPHA Resource"
}

variable "default_tags" {
  type = map(string) #sirve para decir que la variable es un mapa de strings, es decir, un conjunto de pares clave-valor donde la clave es un string y el valor es un string
  default = {
    company    = "TechCorp"
    managed_by = "terraform"
  }
}

variable "environment_tags" {
  type = map(string)
  default = {
    environment = "production"
    cost_center = "cc-123"
  }
}
