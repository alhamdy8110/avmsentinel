# Azure Landing Zone (ALZ) Terraform Module
# This module deploys Log Analytics Workspace with Sentinel and Data Collection Rule
# Note: Management Group and Subscription are assumed to already exist

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource Group for ALZ core resources
module "alz_core_resource_group" {
  source = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"
  
  name = var.core_resource_group_name
  location = var.location
  
  tags = merge(var.tags, {
    purpose = "alz-core"
    environment = var.environment
  })
}

# Log Analytics Workspace for centralized logging
# Using Azure Verified Module following ALZ best practices
module "alz_log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "~> 0.4"
  
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.alz_core_resource_group.name
  
  # Retention and SKU configuration
  retention_in_days = var.log_retention_days
  sku               = var.log_analytics_sku
  
  # Enable daily quota in GB (optional, set to null for unlimited)
  daily_quota_gb = var.log_analytics_daily_quota_gb
  
  # Internet ingestion and query access
  internet_ingestion_enabled = var.log_analytics_internet_ingestion_enabled
  internet_query_enabled     = var.log_analytics_internet_query_enabled
  
  # Tags following ALZ standards
  tags = local.common_tags
}

# Microsoft Sentinel - Security Information and Event Management (SIEM)
# Enable Sentinel on the Log Analytics Workspace
# Sentinel is enabled by onboarding the workspace
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  count                      = var.enable_sentinel ? 1 : 0
  workspace_id               = module.alz_log_analytics.resource.id
  customer_managed_key_enabled = var.sentinel_customer_managed_key_enabled
}

# Microsoft Sentinel Data Connectors
# Azure Active Directory connector
resource "azurerm_sentinel_data_connector_azure_active_directory" "sentinel_aad" {
  count                      = var.enable_sentinel && var.enable_sentinel_data_connectors ? 1 : 0
  name                       = "AzureActiveDirectory"
  log_analytics_workspace_id = module.alz_log_analytics.resource.id
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}

# Azure Activity connector
resource "azurerm_sentinel_data_connector_azure_activity" "sentinel_activity" {
  count                      = var.enable_sentinel && var.enable_sentinel_data_connectors ? 1 : 0
  name                       = "AzureActivity"
  log_analytics_workspace_id = module.alz_log_analytics.resource.id
  subscription_id            = data.azurerm_client_config.current.subscription_id
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}

# Microsoft Sentinel Analytics Rules (optional)
# Uncomment and configure as needed
# resource "azurerm_sentinel_alert_rule_scheduled" "example" {
#   count                      = var.enable_sentinel && var.enable_sentinel_analytics_rules ? 1 : 0
#   name                       = "Example Scheduled Alert Rule"
#   log_analytics_workspace_id = module.alz_log_analytics.resource.id
#   display_name               = "Example Alert"
#   severity                   = "Medium"
#   query                      = "AzureActivity | where OperationName == 'Create or Update Virtual Machine'"
#   enabled                    = true
#   depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
# }

# Data Collection Rule (DCR) for custom data ingestion
# Using azapi provider as DCR is not fully supported in azurerm provider
resource "azapi_resource" "data_collection_rule" {
  count     = var.enable_data_collection_rule ? 1 : 0
  type      = "Microsoft.Insights/dataCollectionRules@2022-06-01"
  name      = local.data_collection_rule_name
  location  = var.location
  parent_id = module.alz_core_resource_group.id

  body = jsonencode({
    properties = {
      # Data Sources Configuration
      dataSources = var.data_collection_rule_data_sources
      
      # Destinations - Log Analytics Workspace
      destinations = {
        logAnalytics = [
          {
            workspaceResourceId = module.alz_log_analytics.resource.id
            name                = "logAnalyticsDestination"
          }
        ]
      }
      
      # Data Flows - Define how data flows from sources to destinations
      dataFlows = var.data_collection_rule_data_flows
      
      # Description
      description = var.data_collection_rule_description
    }
    
    kind = var.data_collection_rule_kind
    tags = local.common_tags
  })

  schema_validation_enabled = false
  ignore_missing_property   = true
}

# Role Assignment for Data Collection Rule
# Grants the DCR permission to write to Log Analytics Workspace
resource "azurerm_role_assignment" "dcr_to_law" {
  count                = var.enable_data_collection_rule && var.enable_dcr_role_assignment ? 1 : 0
  scope                = module.alz_log_analytics.resource.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = try(azapi_resource.data_collection_rule[0].identity[0].principal_id, null)
  
  depends_on = [azapi_resource.data_collection_rule]
}

