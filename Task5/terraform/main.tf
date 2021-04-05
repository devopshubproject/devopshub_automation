##################################################
# Providers
##################################################

provider "azurerm" {
  version = ">=2.5.0"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

##################################################
# Azure resource group
##################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.location}-${var.app_name}-rg"
  location = "${var.location}"
  tags                         = "${local.common_tags}"
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
# Create Azure KV
##################################################

resource "azurerm_key_vault" "kv" {
  name                = "${var.app_name}-kv"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  
  enabled_for_deployment          = "${var.enabled_for_deployment}"
  enabled_for_disk_encryption     = "${var.enabled_for_disk_encryption}"
  enabled_for_template_deployment = "${var.enabled_for_template_deployment}"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  sku_name  = "standard"
  tags                = "${local.common_tags}"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

##################################################
# Create Azure KV Default Policy
##################################################
resource "azurerm_key_vault_access_policy" "default_policy" {
  key_vault_id = "${azurerm_key_vault.kv.id}"
  tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
  object_id    = "${data.azurerm_client_config.current.object_id}"

  lifecycle {
    create_before_destroy = true
  }

  key_permissions = "${var.kv-key-permissions}"
  secret_permissions = "${var.kv-secret-permissions-full}"
  certificate_permissions = "${var.kv-certificate-permissions-full}"
  storage_permissions = "${var.kv-storage-permissions-full}"
}

##################################################
# Create Azure KV  Policy
##################################################
resource "azurerm_key_vault_access_policy" "policy" {
  for_each                = "${var.policies}"
  key_vault_id            = azurerm_key_vault.key-vault.id
  tenant_id               = lookup(each.value, "tenant_id")
  object_id               = lookup(each.value, "object_id")
  key_permissions         = lookup(each.value, "key_permissions")
  secret_permissions      = lookup(each.value, "secret_permissions")
  certificate_permissions = lookup(each.value, "certificate_permissions")
  storage_permissions     = lookup(each.value, "storage_permissions")
}