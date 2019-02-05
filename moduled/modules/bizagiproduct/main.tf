
/*locals {
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString B1z4g1 -AsPlainText -Force"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.domain_name}.com -DomainNetbiosName ${upper(var.domainName)} -ForestMode Win2012R2 -SafeModeAdministratorPassword $password -InstallDns:$true -Force:$true"
  shutdown_command     = "shutdown -r -t 15"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.install_ad_command}; ${local.import_command}; ${local.password_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}
*/

resource "azurerm_storage_account" "st" {
    name                     = "${replace("${var.name}", "-", "")}"
    resource_group_name      = "${var.resource_group_name}"
    location                 = "${var.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_public_ip" "vm" {
    name                         = "${var.name}${var.product_purpose}${var.node_number}ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.resource_group_name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-${var.product_purpose}-${var.node_number}"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "modules-test"
    }
}

resource "azurerm_network_interface" "vm" {
    name                = "${var.name}${var.product_purpose}${var.node_number}ni"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        public_ip_address_id          = "${azurerm_public_ip.vm.id}"
        private_ip_address            = "10.0.2.20"
    }
}
resource "azurerm_virtual_machine" "vm" {
    name                          = "${var.name}-${var.product_purpose}-${var.node_number}"
    location                      = "${var.location}"
    resource_group_name           = "${var.resource_group_name}"
    network_interface_ids         = ["${azurerm_network_interface.vm.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true
/*
    storage_image_reference {
        publisher     = "${var.image_publisher}"  
        offer         = "${var.image_offer}"
        sku           = "${var.image_sku}"
        version       = "${var.image_version}"
    }*/

    storage_os_disk {
        name          = "${var.name}-${var.product_purpose}-osdisk-${var.node_number}"
        caching       = "ReadWrite"
        image_uri     = "${var.product_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-${var.product_purpose}-osdisk-${var.node_number}.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-${var.product_purpose}-${var.node_number}"
    admin_username = "${var.name}"
    admin_password = "${var.name}${var.product_purpose}${var.node_number}Psw"
  }

    os_profile_windows_config {
        enable_automatic_upgrades = true
        provision_vm_agent        = true
        timezone                  = "SA Pacific Standard Time" 
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "modules-test"
    }
}
