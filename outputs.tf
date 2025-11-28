# ALZ Outputs Configuration

output "core_resource_group_id" {
  description = "ID of the core resource group"
  value       = module.alz_core_resource_group.id
}

output "core_resource_group_name" {
  description = "Name of the core resource group"
  value       = module.alz_core_resource_group.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.alz_log_analytics.resource.id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = try(module.alz_log_analytics.primary_shared_key, null)
  sensitive   = true
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = try(module.alz_log_analytics.primary_shared_key, null)
  sensitive   = true
}

output "log_analytics_workspace_secondary_shared_key" {
  description = "Secondary shared key for the Log Analytics workspace"
  value       = try(module.alz_log_analytics.secondary_shared_key, null)
  sensitive   = true
}

output "log_analytics_workspace_customer_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace"
  value       = module.alz_log_analytics.resource.workspace_id
}

# Microsoft Sentinel Outputs
output "sentinel_enabled" {
  description = "Whether Microsoft Sentinel is enabled on the Log Analytics Workspace"
  value       = var.enable_sentinel
}

output "sentinel_workspace_id" {
  description = "The ID of the Sentinel workspace onboarding"
  value       = var.enable_sentinel ? try(azurerm_sentinel_log_analytics_workspace_onboarding.sentinel[0].workspace_id, null) : null
}

output "sentinel_data_connectors" {
  description = "Microsoft Sentinel data connectors configuration"
  value = {
    azure_active_directory = var.enable_sentinel && var.enable_sentinel_data_connectors ? {
      id   = try(azurerm_sentinel_data_connector_azure_active_directory.sentinel_aad[0].id, null)
      name = try(azurerm_sentinel_data_connector_azure_active_directory.sentinel_aad[0].name, null)
    } : null
    azure_activity = var.enable_sentinel && var.enable_sentinel_data_connectors ? {
      id   = try(azurerm_sentinel_data_connector_azure_activity.sentinel_activity[0].id, null)
      name = try(azurerm_sentinel_data_connector_azure_activity.sentinel_activity[0].name, null)
    } : null
  }
}

# Data Collection Rule Outputs
output "data_collection_rule_id" {
  description = "The ID of the Data Collection Rule"
  value       = var.enable_data_collection_rule ? try(azapi_resource.data_collection_rule[0].id, null) : null
}

output "data_collection_rule_name" {
  description = "The name of the Data Collection Rule"
  value       = var.enable_data_collection_rule ? local.data_collection_rule_name : null
}

output "data_collection_rule_endpoint" {
  description = "The endpoint URL for the Data Collection Rule"
  value       = var.enable_data_collection_rule ? try(azapi_resource.data_collection_rule[0].output.properties.endpoint, null) : null
}

# Backend configuration for other modules
output "backend_config" {
  description = "Backend configuration for other Terraform modules"
  value = {
    resource_group_name  = module.alz_core_resource_group.name
    storage_account_name = "tfstate${replace(module.alz_core_resource_group.name, "-", "")}"
    container_name       = "tfstate"
    key                  = "alz-foundation.terraform.tfstate"
  }
}

