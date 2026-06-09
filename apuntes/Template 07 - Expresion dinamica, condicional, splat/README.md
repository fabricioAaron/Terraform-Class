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