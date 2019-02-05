
variable "location" {
  description = "region where the resources should exist"
  default     = "eastus"
}

variable "name" {
    description = "Virtual machine and resources name"
}

variable "nsr_in_winrm_name"{
    description = "inbound network security rule for winrm"
}

variable "resource_group_name" {
    description = "The name of the Resource Group for the environment being created"
}
