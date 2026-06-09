variable "environment" { #aquí se define una variable llamada "environment", que es de tipo string, y tiene una descripción y un valor por defecto, en este caso el valor por defecto es "staging"
  type        = string
  description = "el tipo de entorno name (dev, prod, staging)"
  default     = "dev"
}

variable "storage_disk" { #aquí se define una variable llamada "storage_disk", que es de tipo number, y tiene una descripción y un valor por defecto, en este caso el valor por defecto es 40
  type        = number
  description = "se añade el espacio del disco de nuesto mv (SO) "
  default     = 40
}

variable "vm_delete" {
  type        = bool
  description = "si se quiere eliminar el disco del SO al eliminar la máquina virtual"
  default     = true
}

#list es una estructura de datos ordenada que puede contener elementos duplicados, y se accede a los elementos por índice, utilizando la función element() o la sintaxis de corchetes []
variable "ubicacion_permitida" {
  type        = list(string)
  description = "lista de ubicaciones permitidas para desplegar los recursos"
  default     = ["Norway East", "Spain Central", "france central"]
}

variable "etiqueta_recursos" {
  type        = map(string) #aquí se define una variable llamada "etiqueta_recursos", que es de tipo mapa de string, y tiene una descripción y un valor por defecto, en este caso el valor por defecto es un mapa con una clave "environment" y un valor "staging"
  description = "etiquetas para aplicar a los recursos"
  default = {
    environment = "staging"
    managed_by  = "terraform"
    department  = "DevOps"
  }
}


#tuple es una estructura de datos ordenada e inmutable que puede contener elementos de diferentes tipos, y se accede a los elementos por índice, utilizando la función element() o la sintaxis de corchetes []
variable "configuración_network" {
  type        = tuple([string, string, number])
  description = "configuración de red para la máquina virtual( vnet adress, subnet address, y número de IPs privadas)"
  default     = ["10.0.0.0/16", "10.0.2.0/24", 24]
}


variable "sizes_vm" {
  type        = list(string) #aquí se define una variable llamada "sizes_vm", que es de tipo lista de string, y tiene una descripción y un valor por defecto, en este caso el valor por defecto es una lista con tres tamaños de máquina virtual permitidos
  description = "lista de tamaños de máquina virtual permitidos"
  default     = ["Standard_B2as_v2", "Standard_B1as_v2", "Standard_B1s"]
}

# tipo objedo 

variable "vm_config" {
  type = object({
    size      = string
    publisher = string
    offer     = string
    sku       = string
    version   = string

  })
  description = "configuración de la máquina virtual"
  default = {
    size      = "Standard_B2as_v2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#variable "nombre_storage" {
#  type = list(string) 
#  default = ["templatestorage12" ,"templatestorage13"]
#}

variable "for_each_nombre_storage" {
  type    = set(string)
  default = ["templatestorage12", "templatestorage13"]
}
