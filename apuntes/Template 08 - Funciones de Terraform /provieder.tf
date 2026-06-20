terraform {
  required_providers { #aquí se definen los proveedores que se van a utilizar, en este caso el proveedor de Azure
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.65.0"
        }
  }

  required_version = ">=1.14.0" #aquí se define la versión mínima de terraform que se requiere para ejecutar este código
}

provider "azurerm" { 
    features {
      
    }
  
}