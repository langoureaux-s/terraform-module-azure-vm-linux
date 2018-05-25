output "public_dns_list" {
  value = "${join(",", azurerm_public_ip.public_ip.*.fqdn)}"
}

output "private_dns_list" {
  value = "${join(",", azurerm_network_interface.interface.*.internal_fqdn)}"
}