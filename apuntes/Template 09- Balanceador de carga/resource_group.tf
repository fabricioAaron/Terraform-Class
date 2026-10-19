resource "random_pet" "lb_hostname" {

}

resource "azurerm_resource_group" "rg" {
  name     = "rg-balanceador-carga"
  location = var.location
}
