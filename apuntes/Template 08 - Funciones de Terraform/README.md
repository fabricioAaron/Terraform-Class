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

la función de substr sirve para cortar los primeros caracteres de una variable, por ejemplo : "abcdefghijklmnopqrstuvwxyz" corta los primeros 23 caracteres y nos los devuelve, esto es util para acortar los nombres de las variables de azurerm porque tiene un limite de 24 caracteres

```bash

local {
  storage_formatted = substr(var.storage_account_name, 0, 23) #sirve para corta los primeros 23 caracteres de la variable storage_account_name y lo guarda en la variable storage_formatted
}


```
en nuestro main: 

resource "azurerm_storage_account" "example" {

  name                     = local.storage_formatted #llamamos a la variable local.storage_formatted 
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.merge_tags #aca usamos el merge_tags para que se guarden las etiquetas
}

lo guardaremos en nuestra etiqueta y lo sacaremo con el output, lo que conseguimos cuando nos de el plan nos diga que excedemos las 23 caracteres y nos de un error de que no se puede crear la cuenta de almacenamiento

output "storage_name" {
  value = azurerm_storage_account.example.name
}


## Function Focus: `split, join`

Estas funciones sirven para dividir (split) un string en una lista y para unir (join) una lista en un solo string.

En nuestro `main.tf` utilizamos `split` para separar un string de puertos (separados por comas) en una lista real. Esto nos sirve para iterar sobre esa lista y crear configuraciones específicas, como reglas de red:

```hcl
locals {
  # split toma un separador (",") y el string a dividir (var.allowed_ports)
  formatted_ports = split(",", var.allowed_ports)
  
  # Iteramos con un bucle for sobre la lista resultante para generar una estructura de reglas
  nsg_rules = [for port in local.formatted_ports : {
    name        = "port-${port}"
    port        = port
    description = " allowed traffic on port : ${port}"
    }
  ]
}
```

Si quisiéramos hacer lo inverso y unir una lista de elementos en un solo string, usaríamos `join`. Por ejemplo, para unir nuestra lista de puertos usando un guión:

```hcl
locals {
  # join toma el separador ("-") y la lista a unir (local.formatted_ports)
  joined_ports = join("-", local.formatted_ports)
}
```

Finalmente, usamos un output en `main.tf` para ver el resultado de cómo estructuramos las reglas gracias al uso previo de `split`:

```hcl
output "nsg" {
  value = local.nsg_rules
}
```


# Assignment 5: Resource Lookup

Function Focus: lookup

Scenario:
Implement environment configuration mapping with fallback values.