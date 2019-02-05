variable "credential" {
  type = "map"
}

variable "product_vhd"{
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

variable "domain_name"{
    description = "name of active diretory domain"
}

variable "product_purpose"{}
