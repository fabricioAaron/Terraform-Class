terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "tfstatefabri2026"
    container_name       = "tfstate"
    key                  = "balanceador-carga.terraform.tfstate"
  }
}
