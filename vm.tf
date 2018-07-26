variable "credential" {
  type = "map"
}


variable "location" {
  description = "region where the resources should exist"
  default     = "eastus"
}


variable "name" {
    description = "Virtual machine and resources name"
}

provider "azurerm" {
  subscription_id = "${var.credential["subscription_id"]}"
  client_id       = "${var.credential["client_id"]}"
  client_secret   = "${var.credential["client_secret"]}"
  tenant_id       = "${var.credential["tenant_id"]}"
}


resource "azurerm_resource_group" "vm" {
    name = "${var.name}rg"
    location = "${var.location}"
}

resource "azurerm_storage_account" "st" {
    name = "staccountststst"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    location = "${var.location}"
    account_tier = "Standard"
    account_replication_type = "LRS"
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_storage_container" "st" {
    name = "scripts"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    storage_account_name = "${azurerm_storage_account.st.name}"
    container_access_type = "blob"
}

resource "azurerm_storage_blob" "st" {
    name = "install.ps1"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    storage_account_name = "${azurerm_storage_account.st.name}"
    storage_container_name = "${azurerm_storage_container.st.name}"
    type = "block"
    source = "install.ps1"
}

resource "azurerm_virtual_network" "vm" {
    name = "${var.name}vn"
    address_space = ["10.0.0.0/16"]
    location = "${var.location}"
    resource_group_name = "${var.name}rg"
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_subnet" "vm" {
    name = "${var.name}sub"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    virtual_network_name = "${azurerm_virtual_network.vm.name}"
    address_prefix = "10.0.2.0/24"
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_public_ip" "vm" {
    name = "${var.name}ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    idle_timeout_in_minutes = 30


    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "vm" {
    name = "${var.name}ni"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.vm.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_managed_disk" "vm" {
    name                 = "${var.name}datadisk_existing"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    disk_size_gb         = "1023"
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_virtual_machine" "vm" {
    name = "${var.name}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    network_interface_ids = ["${azurerm_network_interface.vm.id}"]
    vm_size = "Standard_DS1_v2"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    depends_on                = ["azurerm_resource_group.vm"]

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk1"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name = "hostname"
        admin_username = "${var.name}"
        admin_password = "${var.name}1Psw"
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }

    tags {
        environment = "test"
    }
}

resource "azurerm_virtual_machine_extension" "vm" {
    name = "update"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File install.ps1"
        }
    SETTINGS
    depends_on                = ["azurerm_virtual_machine.vm"]
}