# Development Environment Configuration

location      = "East US"
location_short = "eus"

# Log Analytics configuration for development
log_retention_days                    = 7
log_analytics_daily_quota_gb          = null  # Unlimited
log_analytics_internet_ingestion_enabled = false
log_analytics_internet_query_enabled   = false

# Microsoft Sentinel configuration
enable_sentinel                  = true
enable_sentinel_data_connectors  = true
sentinel_customer_managed_key_enabled = false

# Data Collection Rule configuration
enable_data_collection_rule      = true
enable_dcr_role_assignment       = true
data_collection_rule_description = "Development Data Collection Rule for Log Analytics Workspace"
data_collection_rule_kind        = "Linux"

# Tags for development
tags = {
  Environment = "Development"
  Project     = "ALZ Foundation"
  Owner       = "DevOps Team"
  CostCenter  = "IT-001"
}

