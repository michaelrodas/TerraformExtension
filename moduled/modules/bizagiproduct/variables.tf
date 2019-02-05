variable "name" {
    description = "Virtual machine and resources name"
}

variable "location" {
  description = "region where the resources should exist"
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the Resource Group for the environment being created"
}

variable "subnet_id" {
  description = "Subnet for NIC"
}

variable "product_purpose" {
  description = "Determines if the VM is BPM, BAS or Scheduler"
}

variable "node_number" {
  description = "Determines the number of VM being created"
}

variable "vm_size" {
  description = "size of the vm to create"
}
/*
variable "image_publisher"{
    description = "Company who owns the software"
}

variable "image_offer"{
    description = "Operating system"
}

variable "image_sku"{
    description = "sku"
}

variable "image_version"{}
*/

variable "storage_name"{
  description ="storage new vhd"
}

variable "product_vhd"{
  description ="storage uri of bpm vhd"
}
/*
variable "dnsdb"{
    description = "database conectionString"
}*/
/*
variable "domainName"{
    description = "name of active diretory domain"
}*/
