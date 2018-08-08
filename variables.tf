variable "location" {
    description = "The Azure Region in which the Resource Group exists"
}

variable "rg_name" {
    description = "The name of the Resource Group where VM resources will be created"
}

variable "subnet_id" {
    description = "The Subnet ID which the VM's NIC should be created in"
}

variable "name" {
    description = "The Prefix used for the VM's resources and for the VM hostname"
}

variable "size" {
    description = "The VM model"
}

variable "count" {
    description = "The number of VM instance should be created"
}

variable "cloudconfig_file" {
    description = "The cloud config full path file"
    default = ""
}

variable "admin_username" {
    description = "The username associated with the local administrator account on the VM"
}

variable "admin_password" {
  description = "The password associated with the local administrator account on the VM"
}

variable "network" {
    description = "The network to allocate static IP"
}

variable "start_ip" {
    description = "Where the IP allocation begin for static private IP"
}

variable "subdomain" {
    description = "The subdomain to use for public FQDN"
}

variable "private_domain" {
    description = "The private domain to resolv as FQDN"
    default = ""
}

variable "data_disk_size" {
    description = "The data disk size in Gb"
    default = "30"
}


variable "tags" {
    description = "List of tags should be associated on all ressoruces"
    type = "map"
    default = {
        module = "module-azure-vm-linux"
    }
}


