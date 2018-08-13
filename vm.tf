variable "credential" {
  type = "map"
}

variable "bpm_vhd"{
  description ="storage uri of bpm vhd"
}


variable "sql_vhd"{
  description ="storage uri of sql vhd"
}

variable "cli_vhd"{
  description ="storage uri of cli vhd"
}

variable "storage_name"{
  description ="storage new vhd"
}
variable "location" {
  description = "region where the resources should exist"
  default     = "eastus"
}

variable "vm_size" {
  description = "size of the vm to create"
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
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_storage_blob" "st" {
    name = "install.ps1"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    storage_account_name = "${azurerm_storage_account.st.name}"
    storage_container_name = "${azurerm_storage_container.st.name}"
    type = "block"
    source = "install.ps1"
    depends_on                = ["azurerm_resource_group.vm"]
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
    domain_name_label            = "${var.name}-bpm-1"
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
resource "azurerm_virtual_machine" "vm" {
    name = "${var.name}-bpm-1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"
    network_interface_ids = ["${azurerm_network_interface.vm.id}"]
    vm_size = "${var.vm_size}"
    delete_os_disk_on_termination = true
    depends_on                = ["azurerm_resource_group.vm"]

    storage_os_disk {
        name = "${var.name}bpmosdisk1"
        caching = "ReadWrite"
        image_uri     = "${var.bpm_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhdtemplate/${var.name}-bpm-1osdisk.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-bpm-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}bpm1Psw"
  }

    os_profile_windows_config {
        provision_vm_agent = true
        winrm ={
            protocol="http"
        }

    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_virtual_machine_extension" "vm" {
    name = "BPM"
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
            "commandToExecute": "powershell.exe -File install.ps1 -componentName BPM -channel QA -machineName name -dnsdb '\"Persist Security Info=True;User ID=sa;Password=B1z4g1;Data Source=RNF-AUT-SQL-1;Initial Catalog=RNF;\"'"
        }
    SETTINGS
    depends_on                = ["azurerm_virtual_machine.vm"]
}
