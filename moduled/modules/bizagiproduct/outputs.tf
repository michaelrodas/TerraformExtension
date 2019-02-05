output "public_ip_address" {
  value = "${azurerm_public_ip.vm.ip_address}"
}