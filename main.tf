terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}

provider "azurerm" {}

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.count}"
  name                         = "vm_${var.name}${count.index}_public_ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.subdomain}-${var.name}${count.index}"
  tags = "${var.tags}"
}

resource "azurerm_network_interface" "interface" {
  count                   = "${var.count}"
  name                    = "vm_${var.name}${count.index}_interface"
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
    name              = "vm_${var.name}${count.index}_disk_system"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "${var.os_disk_size}"
  }
  os_profile {
    computer_name  = "${var.name}${count.index}.hm.dm.ad"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data = "${var.cloudconfig_file == "" ? file("${path.module}/file/cloud-config.yml") : file("${var.cloudconfig_file}")}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${var.tags}"
}

resource "azurerm_virtual_machine_extension" "custom_command" {
    count                       = "${var.count}"
    name                        = "CustomScript"
    location                    = "${var.location}"
    resource_group_name         = "${var.rg_name}"
    virtual_machine_name        = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
    publisher                   = "Microsoft.Azure.Extensions"
    type                        = "CustomScript"
    type_handler_version        = "2.0"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
     {
       "script": "${var.custom_script_path == "" ? base64gzip(file("${path.module}/file/custom-script.sh")) : base64gzip(file("${var.custom_script_path}"))}"
     }
SETTINGS

    tags = "${var.tags}"
}