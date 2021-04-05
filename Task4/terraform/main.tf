##################################################
# Providers
##################################################

provider "azurerm" {
  version = ">=2.5.0"
  features {}
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
# Azure resource group
##################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.location}-${var.app_name}-rg"
  location = "${var.location}"
  tags                         = "${local.common_tags}"
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
# Create Public IP
##################################################

resource "azurerm_public_ip" "pip" {
  name                         = "${var.app_name}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  sku                          = "Basic" 
  allocation_method            = "Dynamic"
  domain_name_label            = "${var.app_name}"
  tags                         = "${local.common_tags}"
}

##################################################
# Create Azure Load Balancer
##################################################

resource "azurerm_lb" "lb" {
  name                = "${var.app_name}-lb"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  sku                 = "Basic"
  tags                = "${local.common_tags}"

  frontend_ip_configuration {
    name                          = "${var.app_name}-fpip"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    #private_ip_address            = "${var.lb_pvtip}"
    #private_ip_address_allocation = "Dynamic"
  }
}

##################################################
# Create ALB Backend Pool
##################################################

resource "azurerm_lb_backend_address_pool" "bap" {
  name                = "${var.app_name}-bap"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
}

##################################################
# Create ALB Health Probe
##################################################

resource "azurerm_lb_probe" "probe" {
  count               = "${length(var.lb_probe)}"
  name                = "${element(keys(var.lb_probe), count.index)}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  protocol            = "${element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)}"
  port                = "${element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)}"
  interval_in_seconds = "${var.lb_probe_interval}"
  number_of_probes    = "${var.lb_probe_unhealthy_threshold}"
  request_path        = "${element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)}"
}

##################################################
# Create ALB Health Probe
##################################################

resource "azurerm_lb_rule" "lbrule" {
  count                          = "${length(var.lb_port)}"
  name                           = "${element(keys(var.lb_port), count.index)}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "${element(var.lb_port[element(keys(var.lb_port), count.index)], 1)}"
  frontend_port                  = "${element(var.lb_port[element(keys(var.lb_port), count.index)], 0)}"
  backend_port                   = "${element(var.lb_port[element(keys(var.lb_port), count.index)], 2)}"
  frontend_ip_configuration_name = "lbip"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bap.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${element(azurerm_lb_probe.probe.*.id, count.index)}"
}