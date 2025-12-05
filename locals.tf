# ALZ Locals Configuration
# Following ALZ Terraform Accelerator patterns

locals {
  # Resource naming convention following ALZ best practices
  name_prefix = var.location_short
  
  # Log Analytics Workspace configuration
  log_analytics_workspace_name = coalesce(
    var.log_analytics_workspace_name,
    "law-${local.name_prefix}-${substr(md5(var.core_resource_group_name), 0, 4)}"
  )
  
  # Sentinel configuration
  sentinel_name = coalesce(
    var.sentinel_name,
    "sentinel-${local.name_prefix}"
  )
  
  # Data Collection Rule naming
  data_collection_rule_name = coalesce(
    var.data_collection_rule_name,
    "dcr-${local.name_prefix}-${substr(md5(var.core_resource_group_name), 0, 4)}"
  )
  
  # Common tags following ALZ standards
  common_tags = merge(
    var.tags,
    {
      ManagedBy       = "Terraform"
      Module          = "alz-log-analytics-sentinel"
      CostCenter      = try(var.tags.CostCenter, "IT-001")
      Compliance      = try(var.tags.Compliance, "Standard")
    }
  )
}

