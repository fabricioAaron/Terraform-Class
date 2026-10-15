terraform {
  required_providers { #aquí se definen los proveedores que se van a utilizar, en este caso el proveedor de Azure
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.65.0"
        }
# version = "4.65.0" → solo exactamente 4.65.0.
# version = ">= 4.65.0" → cualquier versión igual o superior (incluye 5.x).
# version = "~> 4.65" → >= 4.65.0 y < 5.0.0 (permite cualquier 4.x >=4.65.0).
# version = "~> 4.65.0" → >= 4.65.0 y < 4.66.0 (tu caso).
  }
# Ejemplo de mircrosft de en donde se tiene que guardar el backen : https://learn.microsoft.com/es-es/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
    backend "azurerm" {
    access_key           = "tfstate-temp02"        # Can also be set via `ARM_ACCESS_KEY` environment variable.
    storage_account_name = "temp024"                # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"                 # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "dev.terraform.tfstate"  # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
  required_version = ">=1.14.0" #aquí se define la versión mínima de terraform que se requiere para ejecutar este código
}

provider "azurerm" { #aquí se configura el proveedor de Azure, en este caso se habilita la característica de "features" que es necesaria para utilizar algunos recursos de Azure
    features {
      
    }
  
}



#sería el tipo que recurso que quiero aplicar 
resource "azurerm_resource_group" "example" { #lo que esta entre comidas es el nombre del recurso, que es  interno para terraform, no tiene que ser igual al de azure 
  name     = "example-resources"
  location = "Norway East"
}

resource "azurerm_storage_account" "example" {

  name                     = "template001"
  resource_group_name      = azurerm_resource_group.example.name #aquí se hace referencia al recurso anterior, para que tome el nombre del grupo de recursos creado anteriormente
  location                 = azurerm_resource_group.example.location #sería una dependencia, porque el recurso de la cuenta de almacenamiento depende del grupo de recursos, entonces se hace referencia a la ubicación del grupo de recursos creado anteriormente
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}
