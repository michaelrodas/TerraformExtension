resource "azurerm_virtual_network" "vm" {
    name                = "${var.name}vn"
    address_space       = ["10.0.2.0/24"]
    location            = "${var.location}"
    dns_servers         = ["10.0.2.20"]
    resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.name}nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "vm" {
  name                        = "${var.nsr_in_winrm_name}"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefixes     = ["10.0.2.0/24"]
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.vm.name}"
}

resource "azurerm_subnet" "vm" {
    name                 = "${var.name}sub"
    resource_group_name  = "${var.resource_group_name}"
    virtual_network_name = "${azurerm_virtual_network.vm.name}"
    address_prefix       = "10.0.2.0/24"
}