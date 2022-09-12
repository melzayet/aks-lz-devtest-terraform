########
# DATA #
########

# Data From Existing Infrastructure

data "terraform_remote_state" "existing-lz" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.container_name
    key                  = "lz-net"
    access_key = var.access_key
  }
}

data "azurerm_client_config" "current" {}


output "key_vault_id" {
  value = module.create_kv.kv_id
}

output "container_registry_id" {
  value = module.create_acr.acr_id
}

output "container_registry_name" {
  value = module.create_acr.acr_name
}

output "container_registry_location" {
  value = module.create_acr.acr_location
}

output "container_registry_rg" {
  value = module.create_acr.acr_rg
}


output "object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}









