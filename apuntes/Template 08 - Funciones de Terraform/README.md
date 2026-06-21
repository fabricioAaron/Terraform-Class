# FUNCIONES 

## Functions Focus: `lowe`, `replace`

Para poder inicializar la consola de terraform : ``terraform console ``

En este caso para que podamos cambiar el nombre de nuestro proyecto  usamos la función replace para poder reemplazar los espacios por guiones:

crearemos en nuestras variables lo siguiente:

```bash

variable "proyecto_name" {
  type = string
  description = "nombre del proyecto"
  default = "Project ALPHA Resource"
}

```

En nuestro main.tf : 

en el formato de nuestro nombre : #en esta linea le estamos dizendo que nos reemplace los espacios por guiones de la variable proyecto_name y lo guarde en la variable formatted_name

``` bash

locals { #locals sirve para crear variables locales, es decir, variables que solo se utilizan en este archivo
  formatted_name = replace(var.proyecto_name, " ", "-")
}

resource "azurerm_resource_group" "rg" {
  name     = local.formatted_name
  location = "spain central"

}

output "rgname" {
  value = azurerm_resource_group.rg.name
}

``` 

# Etiquetado de los recursos

## Function Focus: `merge`

Sirve para fucionar las etiquetas en nuestras variables.tf:

``` 
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

```

## Nombramiento de cuenta de almacenamiento

Function Focus: `substr`
