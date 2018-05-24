output "public_dns_list" {
  value = "${join(",", azurerm_public_ip.*.fqdn)}"
}

output "private_dns_list" {
  value = "${join(",", azurerm_network_interface.*.internal_fqdn)}"
}