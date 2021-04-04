##################################################
# Providers
##################################################

provider "azurerm" {
  version = ">=2.5.0"
  features {}
}

##################################################
# Azure resource group
##################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.location}-${var.app_name}-rg"
  location = "${var.location}"
}


##################################################
# locals for taging
##################################################

locals {
  common_tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Application = "${var.app_name}"
    Company     = "${var.company}"
  }
}

##################################################
# Azure Vnet
##################################################

data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
}

##################################################
# Azure Subnet
##################################################

data "azurerm_subnet" "subnet" {
  name = "${var.subnet_name}"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.vnet.resource_group_name}"
}

##################################################
# Application security group
##################################################

resource "azurerm_application_security_group" "asg" {
  name                = "${var.environment}-${var.app_name}-vm-asg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${local.common_tags}"
}


##################################################
# Network security group
##################################################

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.environment}-${var.app_name}-vm-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${local.common_tags}"
}

##################################################
# Network security rules Inbound
##################################################

resource "azurerm_network_security_rule" "rules_inbound" {
  count = "${length(var.rule_portrange)}"
  name                        = element(var.rule_name, count.index)
  priority                    = "${(count.index + 10) * 10}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  description = element(var.rule_description, count.index)
  source_port_range           = "*"
  destination_port_range = element(var.rule_portrange, count.index)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
  destination_application_security_group_ids = [azurerm_application_security_group.asg.id]
}

##################################################
# Network security rules Outbound
##################################################

resource "azurerm_network_security_rule" "rules_outbound" {
  count                       = length(var.outbound_rule_portrange)
  name                        = element(var.outbound_rule_name, count.index)
  direction                   = "Outbound"
  description                 = element(var.outbound_rule_description, count.index)
  source_port_range           = "*"
  destination_port_range      = element(var.outbound_rule_portrange, count.index)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  protocol                    = "Tcp"
  access                      = "Allow"
  priority                    = "${(count.index + 11) * 11}"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

##################################################
# NSG adding to Subnet
##################################################

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = "${data.azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

##################################################
# Create Public IP
##################################################

resource "azurerm_public_ip" "pip" {
  name                         = "${var.app_name}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method            = "Dynamic"
  domain_name_label            = "${var.app_name}"
}

##################################################
# Create NIC
##################################################

resource "azurerm_network_interface" "nic" {
  name                      = "${var.environment}-${var.app_name}-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  #network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name = "${var.ipconf_name}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
  depends_on = ["azurerm_network_security_group.nsg"]
}

##################################################
# Generate random text f
##################################################
resource "random_id" "randomId" {
    keepers = {
        resource_group = "${azurerm_resource_group.rg.name}"
    }
    byte_length = 8
}


##################################################
# Create storage account 
##################################################
resource "azurerm_storage_account" "vmdiagnotics" {
    name                        = "automation${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.rg.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

  tags                = "${local.common_tags}"
}

##################################################
# Create an SSH key
##################################################

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

##################################################
# Create VM
##################################################

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.environment}-${var.app_name}-vm"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  size                = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  admin_username      = "${var.username}"
  
  os_disk {
    name          = "${var.environment}-${var.app_name}-vm-osdisk"
    caching       = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

    computer_name  = "${var.environment}-${var.app_name}-vm"
    #admin_username = "${var.username}"
    #admin_password = "${var.password}"
    custom_data = filebase64("${path.module}/scripts/init.sh")
    disable_password_authentication = "${var.disable_password_authentication}"

  admin_ssh_key {
    username   = "${var.username}"
    public_key = "${tls_private_key.sshkey.public_key_openssh}"
  }
  boot_diagnostics {
      storage_account_uri = "${azurerm_storage_account.vmdiagnotics.primary_blob_endpoint}"
  }
  tags = "${local.common_tags}"

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.username} -i ${azurerm_public_ip.pip.ip_address} --private-key ${tls_private_key.sshkey.public_key_openssh} ../ansible/playbooks/tutum.yml"
    }

  depends_on = ["azurerm_storage_account.vmdiagnotics"]


}

##################################################
# Disk storage
##################################################

resource "azurerm_managed_disk" "disk" {
  name                 = "${var.app_name}-pssd-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "${var.data_disk_type}"
  create_option        = "Empty"
  disk_size_gb         = "${var.data_disk_size}" 
}

resource "azurerm_virtual_machine_data_disk_attachment" "mount_data_disk" {
  virtual_machine_id = "${azurerm_linux_virtual_machine.vm.id}"
  managed_disk_id    = "${azurerm_managed_disk.disk.id}"
  lun                = "10"
  caching            = "None"
}