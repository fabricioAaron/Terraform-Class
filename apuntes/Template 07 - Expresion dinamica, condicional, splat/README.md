# DYNAMIC BLOCK (BLOQUE DINÁMICO)

En terraform hay un bloque especial llamado Dynamic que nos permite crear recursos dinámicos, es decir, recursos que se crean en base a una condición, un bucle o un mapa.  

Para eso usamos local.tf, en la que con un for_each iteramos sobre un mapa o array y creamos un recurso por cada elemento.



dynamic "security_rule" {
    for_each = local.nsg_rules 
    content {
      name                       = security_rule.key #aqui anidamos el clave valor que tenemos llamos al dynamic 
      priority                   = security_rule.value.priority               
      direction                  = "Inbound"                             
      access                     = "Allow"                                   
      protocol                   = "Tcp"                                      
      source_port_range          = "*"                                        
      destination_port_range     = security_rule.value.destination_port_range 
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = security_rule.value.description
    }
  }

* reemplazar la variable por shell

terraform plan -var=environment=s

Estó tendría mayor prioridad

cuando lo ejecutamos el apply tomará: 

 como es verdadero tomará dev-nsg y como es falso tomará stage-nsg

(condición ? valor_si_verdadero : valor_si_falso)

resource "azurerm_network_security_group" "rg" {
  name                = (var.environment == "dev" ? "dev-nsg" : "stage-nsg") #aqui usamos una expresion condicional para definir el nombre de la regla de seguridad https://developer.hashicorp.com/terraform/language/expressions/conditionals
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
***************************************************************
con el for iteramos y podemos sacar todo los valores. 

  output "demo" {
  value = [for count in local.nsg_rules : count.description] #splat expression (un truco para sacar el valor de un mapa o array) sacamos de del local iterando entre los valores.
}


con el splat tenemos que indicar cada valor para que nos lo devuelva. En el caso de que hayamos añadido más propiedades al mapa de nsg_rules, tendremos que añadir cada una de ellas al output

output "splat" {
  value = local.nsg_rules[*].allow_http.description #forma mas facil de sacar el valor de un mapa o array sin usar for. con el punto solo sacamos el valor del conjunto de toda esa regla. 
}


****************************************************************************
el splat funciona con variales listas que lo podemos poner en la array para llamarlo

output "splat" {
  value = var.nombre_storage[0] #splat expression para sacar el valor de un set
}