terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}

provider "azurerm" {}

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.count}"
  name                         = "public_ip_${var.name}${count.index}"
  location                     = "${var.location}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.subdomain}-${var.name}${count.index}"
  tags = "${var.tags}"
}

resource "azurerm_network_interface" "interface" {
  count                   = "${var.count}"
  name                    = "interface_${var.name}${count.index}"
  location                = "${var.location}"
  resource_group_name     = "${var.rg_name}"
  internal_dns_name_label = "${var.name}${count.index}"
  ip_configuration {
    name                          = "private"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${cidrhost(var.network, count.index + var.start_ip)}"
    public_ip_address_id          = "${element(azurerm_public_ip.public_ip.*.id, count.index)}"
  }
  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm" {
  count                            = "${var.count}"
  name                             = "vm_${var.name}${count.index}"
  location                         = "${var.location}"
  resource_group_name              = "${var.rg_name}"
  network_interface_ids            = ["${element(azurerm_network_interface.interface.*.id, count.index)}"]
  vm_size                          = "${var.size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7-CI"
    version   = "latest"
  }
  storage_os_disk {
    name              = "disk_system_${var.name}${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.name}${count.index}"
    admin_username = "${var.admin_login}"
    admin_password = "${var.admin_password}"
    custom_data = "${file("${var.cloudconfig_file}")}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${var.tags}"
}