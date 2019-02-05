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

variable "sch_vhd"{
  description ="storage uri of sch vhd"
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

variable "nsr_in_winrm_name"{
    description = "inbound network security rule for winrm"
}

variable "dnsdb"{
    description = "database conectionString"
}

variable "image_publisher"{
    description = "Company who owns the software"
}

variable "image_offer"{
    description = "Operating system"
}

variable "image_sku"{
    description = "sku"
}

variable "domainName"{
    description = "name of active diretory domain"
}

locals {
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.name}ctrlr1Psw -AsPlainText -Force"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.domainName}.com -DomainNetbiosName ${upper(var.domainName)} -ForestMode Win2012R2 -SafeModeAdministratorPassword $password -InstallDns:$true -Force:$true"
  shutdown_command     = "shutdown -r -t 15"
  exit_code_hack       = "exit 0"
  createad_command     = "${local.install_ad_command}; ${local.import_command}; ${local.password_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
  username_command     = "$username = '${var.domainName}.com\\\\${var.name}'" 
  credential_command   = "$credential = New-Object System.Management.Automation.PSCredential($username,$password)" 
  addvm_command        = "Add-Computer -DomainName ${var.domainName}.com -Credential $credential"
  restart_command      = "shutdown -r -t 1"
  regisdom_command     = "${local.password_command}; ${local.username_command}; ${local.credential_command}; ${local.addvm_command}; ${local.restart_command}; ${local.exit_code_hack}"
}

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

resource "azurerm_storage_account" "st" {
    name                     = "${replace("${var.name}", "-", "")}"
    resource_group_name      = "${azurerm_resource_group.vm.name}"
    location                 = "${var.location}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    depends_on               = ["azurerm_resource_group.vm"]
}

resource "azurerm_storage_container" "st" {
    name                  = "${var.name}stc"
    resource_group_name   = "${azurerm_resource_group.vm.name}"
    storage_account_name  = "${azurerm_storage_account.st.name}"
    container_access_type = "blob"
    depends_on            = ["azurerm_resource_group.vm"]
}

resource "azurerm_storage_blob" "st" {
    name                   = "installbpm.ps1"
    resource_group_name    = "${azurerm_resource_group.vm.name}"
    storage_account_name   = "${azurerm_storage_account.st.name}"
    storage_container_name = "${azurerm_storage_container.st.name}"
    type                   = "block"
    source                 = "installbpm.ps1"
    depends_on             = ["azurerm_resource_group.vm"]
}

resource "azurerm_virtual_network" "vm" {
    name                = "${var.name}vn"
    address_space       = ["10.0.2.0/24"]
    location            = "${var.location}"
    dns_servers         = ["10.0.2.20"]
    resource_group_name = "${azurerm_resource_group.vm.name}"
    depends_on          = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.name}nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
}
/*
resource "azurerm_network_security_rule" "inrdp" {
  name                        = "allow_in_rdp"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = '*'
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.vm.name}"
  network_security_group_name = "${azurerm_network_security_group.vm.name}"
  depends_on           = ["azurerm_virtual_machine_extension.bpm2"]
  
}

resource "azurerm_network_security_rule" "inwinrm" {
  name                        = "allow_in_winrm"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefixes     = ["*"]
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.vm.name}"
  network_security_group_name = "${azurerm_network_security_group.vm.name}"
  depends_on           = ["azurerm_virtual_machine_extension.bpm2"]
  
}
resource "azurerm_network_security_rule" "outwinrm" {
  name                        = "allow_out_winrm"
  priority                    = 200
  direction                   = "outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefixes     = '*'
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.vm.name}"
  network_security_group_name = "${azurerm_network_security_group.vm.name}"
  depends_on           = ["azurerm_virtual_machine_extension.bpm2"]
}
*/

resource "azurerm_subnet" "vm" {
    name                 = "${var.name}sub"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_network_name = "${azurerm_virtual_network.vm.name}"
    address_prefix       = "10.0.2.0/24"
    depends_on           = ["azurerm_resource_group.vm"]
}

# Active directory VM

resource "azurerm_public_ip" "ctrlr1" {
    name                         = "${var.name}ctrl1rip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-ctrlr-1"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "ctrlr1" {
    name                = "${var.name}ctrlr1ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "static"
        public_ip_address_id          = "${azurerm_public_ip.ctrlr1.id}"
        private_ip_address            = "10.0.2.20"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_virtual_machine" "ctrlr1" {
    name                          = "${var.name}-ctrlr-1"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.ctrlr1.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher     = "${var.image_publisher}"  
        offer         = "${var.image_offer}"
        sku           = "${var.image_sku}"
        version       = "latest"
    }

    storage_os_disk {
        name          = "${var.name}-ctrlr-osdisk-1"
        caching       = "ReadWrite"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-ctrlr-osdisk-1.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-ctrlr-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}ctrlr1Psw"
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
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_network.vm"]
}

resource "azurerm_virtual_machine_extension" "ctrlr1" {
    name                 = "ActiveDirectory"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.ctrlr1.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.createad_command}\""
    }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.ctrlr1"]
}

# BPM 1 VM
resource "azurerm_network_interface" "bpm1" {
    name                = "${var.name}bpm1ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.bpm1.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}

resource "azurerm_public_ip" "bpm1" {
    name                         = "${var.name}bpm1ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-bpm-1"
    idle_timeout_in_minutes      = 30


    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_virtual_machine" "bpm1" {
    name                          = "${var.name}-bpm-1"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.bpm1.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-bpm-osdisk-1"
        caching       = "ReadWrite"
        image_uri     = "${var.bpm_vhd}"

        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-bpm-osdisk-1.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-bpm-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}bpm1Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "ext1" {
    name                 = "BPM1"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.bpm1.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installbpm.ps1 -componentName BPM -channel QA -machineName ${azurerm_virtual_machine.bpm1.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient -domain ${var.domainName}.com -username ${var.name}"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.bpm1"]
}

# BPM 2 VM
resource "azurerm_public_ip" "bpm2" {
    name                         = "${var.name}bpm2ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-bpm-2"
    idle_timeout_in_minutes      = 30


    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}
resource "azurerm_network_interface" "bpm2" {
    name                = "${var.name}bpm2ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.bpm2.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "bpm2" {
    name                          = "${var.name}-bpm-2"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.bpm2.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-bpm-osdisk-2"
        caching       = "ReadWrite"
        image_uri     = "${var.bpm_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-bpm-osdisk-2.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-bpm-2"
    admin_username = "${var.name}"
    admin_password = "${var.name}bpm2Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "ext2" {
    name                 = "BPM2"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.bpm2.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installbpm.ps1 -componentName BPM -channel QA -machineName ${azurerm_virtual_machine.bpm2.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient -domain ${var.domainName}.com -username ${var.name}"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.bpm2"]
}

# SQL 1 VM
resource "azurerm_public_ip" "sql1" {
    name                         = "${var.name}sql1ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-sql-1"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "sql1" {
    name                = "${var.name}sql1ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.sql1.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "sql1" {
    name                          = "${var.name}-sql-1"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.sql1.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-sql-osdisk-1"
        caching       = "ReadWrite"
        image_uri     = "${var.sql_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-sql-osdisk-1.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-sql-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}sql1Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "extsql" {
    name                 = "DomainRegistration"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.sql1.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "commandToExecute": "powershell.exe -Command \"${local.regisdom_command}\""
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.sql1"]
}

# CLI 1 VM
resource "azurerm_public_ip" "cli1" {
    name                         = "${var.name}cli1ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-cli-1"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "cli1" {
    name                = "${var.name}cli1ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.cli1.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "cli1" {
    name                          = "${var.name}-cli-1"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.cli1.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-cli-osdisk-1"
        caching       = "ReadWrite"
        image_uri     = "${var.cli_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-cli-osdisk-1.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-cli-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}cli1Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
/*
resource "azurerm_virtual_machine_extension" "ext4" {
    name                 = "cli1"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.cli1.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installcli.ps1 -componentName BPM -channel QA -machineName ${azurerm_virtual_machine.cli1.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.cli1"]

}
*/

# Scheduler 1 VM
resource "azurerm_public_ip" "sch1" {
    name                         = "${var.name}sch1ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-sch-1"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "sch1" {
    name                = "${var.name}sch1ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.sch1.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "sch1" {
    name                          = "${var.name}-sch-1"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.sch1.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-sch-osdisk-1"
        caching       = "ReadWrite"
        image_uri     = "${var.sch_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-sch-osdisk-1.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-sch-1"
    admin_username = "${var.name}"
    admin_password = "${var.name}sch1Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "extsch1" {
    name                 = "SCH1"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.sch1.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installbpm.ps1 -componentName SCHEDULER -channel QA -machineName ${azurerm_virtual_machine.sch1.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient -domain ${var.domainName}.com -username ${var.name}"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.sch1"]
}

# Scheduler 1 VM
resource "azurerm_public_ip" "sch2" {
    name                         = "${var.name}sch2ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-sch-2"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "sch2" {
    name                = "${var.name}sch2ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.sch2.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "sch2" {
    name                          = "${var.name}-sch-2"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.sch2.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-sch-osdisk-2"
        caching       = "ReadWrite"
        image_uri     = "${var.sch_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-sch-osdisk-2.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-sch-2"
    admin_username = "${var.name}"
    admin_password = "${var.name}sch2Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "extsch2" {
    name                 = "SCH2"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.sch2.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installbpm.ps1 -componentName SCHEDULER -channel QA -machineName ${azurerm_virtual_machine.sch1.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient -domain ${var.domainName}.com -username ${var.name}"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.sch2"]
}

#Scheduler 3 VM
resource "azurerm_public_ip" "sch3" {
    name                         = "${var.name}sch3ip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.vm.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label            = "${var.name}-sch-3"
    idle_timeout_in_minutes      = 30

    tags {
        environment = "test"
    }
    depends_on                   = ["azurerm_resource_group.vm"]
}

resource "azurerm_network_interface" "sch3" {
    name                = "${var.name}sch3ni"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.vm.name}"

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = "${azurerm_subnet.vm.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.sch3.id}"
    }
    depends_on                = ["azurerm_resource_group.vm"]
}
resource "azurerm_virtual_machine" "sch3" {
    name                          = "${var.name}-sch-3"
    location                      = "${var.location}"
    resource_group_name           = "${azurerm_resource_group.vm.name}"
    network_interface_ids         = ["${azurerm_network_interface.sch3.id}"]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name          = "${var.name}-sch-osdisk-3"
        caching       = "ReadWrite"
        image_uri     = "${var.sch_vhd}"
        vhd_uri       = "https://${var.storage_name}.blob.core.windows.net/vhds/${var.name}-sch-osdisk-3.vhd"
        create_option = "FromImage"
        os_type       = "Windows"
    }

   os_profile {
    computer_name  = "${var.name}-sch-3"
    admin_username = "${var.name}"
    admin_password = "${var.name}sch3Psw"
  }

    os_profile_windows_config {
        timezone= "SA Pacific Standard Time"
        enable_automatic_upgrades =true
        provision_vm_agent = true
        winrm = {
            protocol="http"
        }
    }
    tags {
        environment = "test"
    }
    depends_on                = ["azurerm_virtual_machine_extension.ctrlr1"]
}

resource "azurerm_virtual_machine_extension" "extsch3" {
    name                 = "SCH3"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.vm.name}"
    virtual_machine_name = "${azurerm_virtual_machine.sch3.name}"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "${azurerm_storage_blob.st.url}"
            ],
            "commandToExecute": "powershell.exe -File installbpm.ps1 -componentName SCHEDULER -channel QA -machineName ${azurerm_virtual_machine.sch1.name} -dnsdb \"${var.dnsdb}\" -providerdb MSSqlClient -domain ${var.domainName}.com -username ${var.name}"
        }
    SETTINGS
    depends_on           = ["azurerm_virtual_machine.sch3"]
}