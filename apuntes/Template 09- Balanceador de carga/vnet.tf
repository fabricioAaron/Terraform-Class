resource "azurerm_virtual_network" "vnet-balanceador" {
  name                = "vnet-balanceador"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name # toma el nombre del grupo de recursos y el .name significa que su nombre seria rg-balanceador-carga. si le pongo .vnet se tomaria el nombre de la variable vnet y el .name significaria 
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "subnetA" {
  name                 = "subnetA"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-balanceador.name
  address_prefixes     = ["10.0.0.0/20"]
}

# Crear los nsg para http, https, ssh

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-rules"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # agregamos un dynamic para poder crear las reglas de seguridad de forma dinamica.
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Después de crear los nsg crear las conexiones nsg a la subnet

resource "azurerm_subnet_network_security_group_association" "nsg-subnetA" {
  subnet_id                 = azurerm_subnet.subnetA.id             # con esto le digo que se tome la id de la subnet que se llama subnetA que estaria dentro de vnet-balanceador par aasociar el nsg.
  network_security_group_id = azurerm_network_security_group.nsg.id # con esto le digo que se tome la id del nsg que se llama nsg que estaria dentro de rg-balanceador-carga y se la asigna a la subnetA.
}

# Creacion de Ip publica para el balanceador de carga

resource "azurerm_public_ip" "mypublicIP" {
  name                = "lbPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]
  domain_name_label   = "${azurerm_resource_group.rg.name}-${random_pet.lb_hostname.id}" # con esto le digo que se tome el nombre del grupo de recursos y se le reste
}


# crar un  balanceador de carga con un fronted IP y un backend pool

resource "azurerm_lb" "myLB" {
  name                = "LB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  # asociación de la IP publica 
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.mypublicIP.id
  }
}

# Crearemos el backend pool

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "backendPool"
  loadbalancer_id = azurerm_lb.myLB.id
}

# Agregar una relga de equilibrador de carga que permita el trafico de internet al backend pool

resource "azurerm_lb_rule" "ruleBL" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.myLB.id
  frontend_ip_configuration_name = azurerm_lb.myLB.frontend_ip_configuration[0].name
  backend_port                   = 80
  frontend_port                  = 80
  protocol                       = "Tcp"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id] # se ha asociado la pool de backend al ruleBL
  probe_id                       = azurerm_lb_probe.http-probe.id
}

# crear un probe,Supervisa continuamente cada servidor del backend (por ejemplo, haciendo ping al puerto 80 cada pocos segundos). Si un servidor falla, la sonda avisa al balanceador para que desvíe el tráfico únicamente a los servidores que siguen sanos.

resource "azurerm_lb_probe" "http-probe" {
  loadbalancer_id = azurerm_lb.myLB.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/" # en caso de que el servidor no este escuchando en el puerto 80, o que este devolviendo un error de tipo 5xx, el balanceador de carga no redirigirá el trafico a ese servidor.
}

# agregamos regla de nat para permitir acceso ssh a las maquinas del backend  

resource "azurerm_lb_nat_rule" "ssh" {
  name                           = "ssh"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.myLB.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
}

# Se crea una IP pública que se asociará al NAT

resource "azurerm_public_ip" "natgwpip" {
  name                = "natgw-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

# Crearemos el servicio de NAT para habilitar el tráfico de salida a las mv del backend

resource "azurerm_nat_gateway" "nat" {
  name                    = "NAT-Gateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

# Asociar el NAT Gateway a la Subnet (para que las VMs salgan a internet a través de él

resource "azurerm_subnet_nat_gateway_association" "sub_nat_association" {
  subnet_id      = azurerm_subnet.subnetA.id  # se toma la id de la subnet que se llama subnetA que estaria dentro de vnet-balanceador para asociar el nat gateway.
  nat_gateway_id = azurerm_nat_gateway.nat.id # se toma la id del nat gateway que se llama nat que estaria dentro de rg-balanceador-carga para asociar el nat gateway a la subnetA.
}

# Asociar esta IP pública al NAT Gateway: 

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.natgwpip.id
}
