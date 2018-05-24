# terraform-module-azure-vm-linux

This module permit to create Linux VM on azure in easy way from Terragrunt

```
terragrunt = {
  terraform {
    source = "git::https://github.com/langoureaux-s/terraform-module-azure-vm-linux.git"
  }
  
  location = "West Europe"
  rg_name               = "bigdata"
  name                  = "master"
  size                  = "Standard_A1_v2"
  count                 = 3
  cloudconfig_contend   = "${file(cloud-config-master.yml)}"
  subdomain             = "mysubdomain"
  subnet_id             = "..."
  admin_username        = "toto"
  admin_password        = "P@ssword$1234"
  network               = "10.2.1.0/24"
  start_ip              = "10"
  tags                  = {
                            environment = "test"
                            project = "test"
                        }
}
```