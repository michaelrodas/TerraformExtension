provider "azurerm" {
  subscription_id = "${var.credential["subscription_id"]}"
  client_id       = "${var.credential["client_id"]}"
  client_secret   = "${var.credential["client_secret"]}"
  tenant_id       = "${var.credential["tenant_id"]}"
}

resource "azurerm_resource_group" "vm" {
    name     = "${var.name}rg"
    location = "${var.location}"
}

module "network" {
  source              = "./modules/network"
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  nsr_in_winrm_name   = "${var.nsr_in_winrm_name}"
}

module "bizagiproduct" {
  source              = "./modules/bizagiproduct"
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  subnet_id           = "${module.network.subnet_id}"
  product_purpose     = "${var.product_purpose}"
  node_number         = "1"
  vm_size             = "${var.vm_size}"
  /*
  publisher           = "${var.image_publisher}"  
  offer               = "${var.image_offer}"
  sku                 = "${var.image_sku}"
  version             = "${var.image_version}"
  */
  storage_name        = "${var.storage_name}"
  product_vhd         = "${var.product_vhd}"
}

output "windows_client_public_ip" {
  value = "${module.bizagiproduct.public_ip_address}"
}

