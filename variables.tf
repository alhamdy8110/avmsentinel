# ALZ Variables Configuration

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Resource Group Configuration
variable "core_resource_group_name" {
  description = "Name of the core resource group"
  type        = string
  default     = "rg-alz-core"
}

# Log Analytics Configuration
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-alz-central"
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "PerGB2018", "Premium", "Standard", "Standalone"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, PerNode, PerGB2018, Premium, Standard, Standalone."
  }
}

variable "log_analytics_daily_quota_gb" {
  description = "The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited)."
  type        = number
  default     = null
}

variable "log_analytics_internet_ingestion_enabled" {
  description = "Should the Log Analytics Workspace allow ingestion from the Internet?"
  type        = bool
  default     = false
}

variable "log_analytics_internet_query_enabled" {
  description = "Should the Log Analytics Workspace allow querying from the Internet?"
  type        = bool
  default     = false
}

variable "location_short" {
  description = "Short location code for naming (e.g., 'eastus' -> 'eus')"
  type        = string
  default     = "eus"
}

# Microsoft Sentinel Configuration
variable "enable_sentinel" {
  description = "Enable Microsoft Sentinel on the Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "sentinel_name" {
  description = "Name for Microsoft Sentinel (optional, will be auto-generated if not provided)"
  type        = string
  default     = null
}

variable "enable_sentinel_analytics_rules" {
  description = "Enable Sentinel analytics rules (optional, requires manual configuration)"
  type        = bool
  default     = false
}

variable "enable_sentinel_data_connectors" {
  description = "Enable default Sentinel data connectors (Azure AD and Azure Activity)"
  type        = bool
  default     = true
}

variable "sentinel_customer_managed_key_enabled" {
  description = "Whether customer managed key is enabled for Sentinel"
  type        = bool
  default     = false
}

# Data Collection Rule Configuration
variable "enable_data_collection_rule" {
  description = "Enable Data Collection Rule for custom data ingestion"
  type        = bool
  default     = true
}

variable "data_collection_rule_name" {
  description = "Name for the Data Collection Rule (optional, will be auto-generated if not provided)"
  type        = string
  default     = null
}

variable "data_collection_rule_description" {
  description = "Description for the Data Collection Rule"
  type        = string
  default     = "Data Collection Rule for Log Analytics Workspace"
}

variable "data_collection_rule_kind" {
  description = "The kind of the Data Collection Rule. Possible values are Linux, Windows, and Agent."
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows", "Agent"], var.data_collection_rule_kind)
    error_message = "Data Collection Rule kind must be one of: Linux, Windows, Agent."
  }
}

variable "data_collection_rule_data_sources" {
  description = "Data sources configuration for the Data Collection Rule"
  type = object({
    performanceCounters = optional(list(object({
      streams                      = list(string)
      samplingFrequencyInSeconds   = number
      counterSpecifiers            = list(string)
      name                         = string
    })), [])
    windowsEventLogs = optional(list(object({
      streams = list(string)
      xPathQueries = list(string)
      name    = string
    })), [])
    syslog = optional(list(object({
      streams    = list(string)
      facilityNames = list(string)
      logLevels  = list(string)
      name       = string
    })), [])
    extensions = optional(list(object({
      streams    = list(string)
      extensionName = string
      extensionSettings = any
      name       = string
    })), [])
  })
  default = {
    performanceCounters = [
      {
        streams                    = ["Microsoft-Perf"]
        samplingFrequencyInSeconds = 60
        counterSpecifiers          = ["\\Processor(_Total)\\% Processor Time", "\\Memory\\Available Bytes"]
        name                       = "perfCounter1"
      }
    ]
    windowsEventLogs = []
    syslog           = []
    extensions       = []
  }
}

variable "data_collection_rule_data_flows" {
  description = "Data flows configuration for the Data Collection Rule"
  type = list(object({
    streams      = list(string)
    destinations = list(string)
    transformKql = optional(string, null)
    outputStream = optional(string, null)
  }))
  default = [
    {
      streams      = ["Microsoft-Perf"]
      destinations = ["logAnalyticsDestination"]
    }
  ]
}

variable "enable_dcr_role_assignment" {
  description = "Enable role assignment for Data Collection Rule to write to Log Analytics Workspace"
  type        = bool
  default     = true
}

# Application Insights Configuration
variable "application_insights_name" {
  description = "Name of the Application Insights resource"
  type        = string
  default     = "appi-alz-central"
}

# Key Vault Configuration
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-alz-secrets"
}

variable "key_vault_network_default_action" {
  description = "Default action for Key Vault network access"
  type        = string
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_default_action)
    error_message = "Key Vault network default action must be either 'Allow' or 'Deny'."
  }
}

variable "key_vault_allowed_ip_ranges" {
  description = "List of allowed IP ranges for Key Vault"
  type        = list(string)
  default     = []
}

variable "key_vault_access_policies" {
  description = "Key Vault access policies"
  type = list(object({
    tenant_id               = string
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

# Network Security Group Configuration
variable "core_nsg_name" {
  description = "Name of the core Network Security Group"
  type        = string
  default     = "nsg-alz-core"
}

variable "core_nsg_rules" {
  description = "Network Security Group rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

