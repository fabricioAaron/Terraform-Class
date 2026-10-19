
resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_terraform_tutorial" {
  name                        = "vmss-terraform"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku_name                    = "Standard_D2s_v4"
  instances                   = 3
  platform_fault_domain_count = 1     # Se refiere a los dominios de fallo, en este caso es 1 porque estamos usando zonas.
  zones                       = ["1"] # Zones required to lookup zone in the startup script

  # Aqui lo que se hace es pasarle el script que se va a ejecutar en cada maquina virtual
  # user_data_base64 lo que hace es encriptar el archivo user-data.sh y pasarlo a base64 encode.

  user_data_base64 = base64encode(file("user-data.sh"))
  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = "azureuser"
      admin_ssh_key {
        username   = "azureuser"
        public_key = file(".ssh/key.pub.pub")
      }
    }
  }

  #  la imagen referencia sirve para poder elegir la imagen que se va a utilizar para crear las maquinas virtuales

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  #  lo que hace esto es crear la interfaz de red y la asociacion de la ip publica al vmss  
  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false

    # Este es el responsable de conectar la maquina virtual al balanceador de carga
    ip_configuration {
      name                                   = "ipconfig"
      subnet_id                              = azurerm_subnet.subnetA.id
      primary                                = true
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  # Evita que terraform vuelva a crear el vmss cuando se cambia el numero de instancias

  lifecycle {
    ignore_changes = [
      instances
    ]
  }

}
