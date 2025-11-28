# Azure Landing Zone (ALZ) - Log Analytics with Sentinel and Data Collection Rule

This module deploys a comprehensive Azure Landing Zone foundation with Log Analytics Workspace, Microsoft Sentinel, and Data Collection Rules, following the [ALZ Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator/tree/main/templates/platform_landing_zone) patterns.

## Overview

The ALZ foundation provides:
- **Log Analytics Workspace**: Centralized logging and monitoring using [Azure Verified Module](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace)
- **Microsoft Sentinel**: Security Information and Event Management (SIEM) enabled on Log Analytics Workspace
- **Data Collection Rules**: Custom data ingestion rules for advanced monitoring
- **Centralized Monitoring**: Unified logging and monitoring
- **Security Foundation**: SIEM capabilities for threat detection and response

**Note**: This module assumes that Management Group and Subscription already exist. It will deploy resources in the current subscription context.

## Architecture

```
[Existing] Management Group (mg-alz-foundation)
    └── [Existing] Subscription (sub-alz-foundation)
        └── Resource Group (rg-alz-core) ← Created by this module
            └── Log Analytics Workspace
                ├── Microsoft Sentinel (SIEM)
                └── Data Collection Rule (DCR)
```

## Features

### Log Analytics Workspace
- **Azure Verified Module**: Uses official Azure Verified Module for best practices
- **Configurable Retention**: Set retention period per environment
- **SKU Options**: Support for Free, PerNode, PerGB2018, Premium, Standard, Standalone
- **Daily Quota**: Optional daily ingestion quota management
- **Network Access**: Configurable internet ingestion and query access

### Microsoft Sentinel
- **Automatic Onboarding**: Sentinel enabled on Log Analytics Workspace
- **Data Connectors**: Pre-configured Azure AD and Azure Activity connectors
- **Extensible**: Easy to add custom analytics rules and data connectors
- **Security Monitoring**: SIEM capabilities for threat detection and response

### Data Collection Rule (DCR)
- **Custom Data Sources**: Performance counters, Windows Event Logs, Syslog, Extensions
- **Flexible Configuration**: Define data flows from sources to destinations
- **Role-Based Access**: Automatic role assignment for DCR to write to Log Analytics
- **Multi-Platform**: Support for Linux, Windows, and Agent-based collection

## Prerequisites

1. **Azure CLI**: Authenticated with appropriate permissions
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Terraform**: Version >= 1.0
   ```bash
   terraform version
   ```

3. **Existing Resources**: Management Group and Subscription should already exist (this module does not create them)

4. **Permissions**: Owner or Contributor role on the target subscription

5. **Providers**: 
   - `azurerm` provider ~> 3.0
   - `azapi` provider ~> 1.0 (for Data Collection Rules)

## Quick Start

### 1. Initialize Terraform

```bash
cd avmsentinel
terraform init
```

### 2. Configure Environment Variables

Edit `dev.tfvars` (or create `prod.tfvars`) with your configuration:

```hcl
environment   = "dev"
location      = "East US"
location_short = "eus"

# Enable Sentinel and DCR
enable_sentinel             = true
enable_data_collection_rule = true
```

### 3. Plan the Infrastructure

```bash
terraform plan -var-file="dev.tfvars" -out tfplan
```

### 4. Apply the Infrastructure

```bash
terraform apply tfplan
```

### 5. Get Outputs

```bash
# Get Log Analytics Workspace ID
terraform output log_analytics_workspace_id

# Get Sentinel workspace ID
terraform output sentinel_workspace_id

# Get Data Collection Rule ID
terraform output data_collection_rule_id
```

## Configuration

### Environment Files

- `dev.tfvars` - Development environment
- `staging.tfvars` - Staging environment
- `prod.tfvars` - Production environment (create as needed)

### Key Variables

#### Log Analytics Workspace

```hcl
log_analytics_workspace_name = "law-alz-central"  # Optional, auto-generated if not provided
log_retention_days          = 30                  # Retention period in days
log_analytics_sku           = "PerGB2018"         # SKU: Free, PerNode, PerGB2018, Premium, Standard, Standalone
log_analytics_daily_quota_gb = null                # null = unlimited, or set specific GB
log_analytics_internet_ingestion_enabled = false  # Internet ingestion access
log_analytics_internet_query_enabled     = false  # Internet query access
```

#### Microsoft Sentinel

```hcl
enable_sentinel                      = true   # Enable Sentinel on workspace
enable_sentinel_data_connectors      = true   # Enable default data connectors
sentinel_customer_managed_key_enabled = false # Customer managed key (optional)
```

#### Data Collection Rule

```hcl
enable_data_collection_rule      = true
data_collection_rule_name       = null  # Optional, auto-generated if not provided
data_collection_rule_kind       = "Linux"  # Linux, Windows, or Agent
data_collection_rule_description = "Data Collection Rule for Log Analytics Workspace"
enable_dcr_role_assignment      = true  # Auto-assign role for DCR to write to LAW

# Data sources configuration
data_collection_rule_data_sources = {
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

# Data flows configuration
data_collection_rule_data_flows = [
  {
    streams      = ["Microsoft-Perf"]
    destinations = ["logAnalyticsDestination"]
  }
]
```

## Advanced Configuration

### Custom Data Collection Rule

Example for Windows Event Logs:

```hcl
data_collection_rule_data_sources = {
  windowsEventLogs = [
    {
      streams    = ["Microsoft-WindowsEvent"]
      xPathQueries = [
        "Security!*[System[(EventID=4624 or EventID=4625)]]",
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
      name = "windowsEventLog1"
    }
  ]
  performanceCounters = []
  syslog              = []
  extensions          = []
}

data_collection_rule_data_flows = [
  {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = ["logAnalyticsDestination"]
  }
]
```

### Custom Sentinel Analytics Rules

Uncomment and configure in `main.tf`:

```hcl
resource "azurerm_sentinel_alert_rule_scheduled" "example" {
  name                       = "Suspicious VM Creation"
  log_analytics_workspace_id = module.alz_log_analytics.resource.id
  display_name               = "Suspicious Virtual Machine Creation"
  severity                   = "High"
  query                      = "AzureActivity | where OperationName == 'Create or Update Virtual Machine' | where Caller != 'system'"
  enabled                    = true
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}
```

## Outputs

### Log Analytics Workspace

- `log_analytics_workspace_id` - ID of the Log Analytics workspace
- `log_analytics_workspace_customer_id` - Workspace (Customer) ID
- `log_analytics_workspace_primary_shared_key` - Primary shared key (sensitive)
- `log_analytics_workspace_secondary_shared_key` - Secondary shared key (sensitive)

### Microsoft Sentinel

- `sentinel_enabled` - Whether Sentinel is enabled
- `sentinel_workspace_id` - Sentinel workspace ID
- `sentinel_data_connectors` - Data connectors configuration

### Data Collection Rule

- `data_collection_rule_id` - ID of the Data Collection Rule
- `data_collection_rule_name` - Name of the Data Collection Rule
- `data_collection_rule_endpoint` - Endpoint URL for the DCR

## Integration with Existing Projects

After deploying this ALZ foundation:

1. **Update Backend Configuration**: Use the `backend_config` output
2. **Reference Resources**: Use the output IDs in other modules
3. **Centralized Logging**: Send logs to the Log Analytics workspace
4. **Security Monitoring**: Configure Sentinel alerts and playbooks
5. **Data Collection**: Associate VMs and resources with the Data Collection Rule

### Example: Associate VM with DCR

```hcl
resource "azurerm_virtual_machine_extension" "dcr_association" {
  name                 = "DcrAssociation"
  virtual_machine_id   = azurerm_linux_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  settings = jsonencode({
    dataCollectionRuleId = module.alz_log_analytics.data_collection_rule_id
  })
}
```

## Security Considerations

- **Sentinel**: Enable data connectors and configure analytics rules
- **Data Collection**: Review DCR data sources to ensure compliance
- **Monitoring**: Enable Security Center and compliance policies
- **Backup**: Configure backup policies for critical resources
- **Encryption**: Consider customer-managed keys for sensitive data

## Cost Optimization

### Development Environment
- 7-day log retention
- Basic SKU (PerGB2018)
- Limited data collection

### Staging Environment
- 30-day log retention
- Standard SKU
- Moderate data collection

### Production Environment
- 90-day log retention (recommended)
- Premium SKU for high-volume scenarios
- Comprehensive data collection
- Customer-managed keys for compliance

## Troubleshooting

### Common Issues

1. **Subscription Context**: Ensure you're authenticated to the correct Azure subscription
2. **Permissions**: Verify Azure CLI authentication and permissions
   ```bash
   az account show
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```
3. **Resource Naming**: Check for naming conflicts (workspace names must be globally unique)
4. **Sentinel Onboarding**: Ensure Log Analytics Workspace is fully provisioned before enabling Sentinel
5. **DCR Role Assignment**: Verify managed identity is created before role assignment

### Commands

```bash
# Check Azure CLI authentication and current subscription
az account show

# Check Log Analytics Workspace
az monitor log-analytics workspace show --resource-group rg-alz-core --workspace-name law-alz-central

# Check Sentinel status
az sentinel workspace show --resource-group rg-alz-core --workspace-name law-alz-central

# Check Data Collection Rule
az monitor data-collection rule show --resource-group rg-alz-core --rule-name dcr-alz-central
```

## Resources Created

**Note**: Management Group and Subscription are assumed to already exist. This module creates the following resources:

### Resource Group
- **Name**: `rg-alz-core` (configurable)
- **Purpose**: Container for core ALZ resources

### Log Analytics Workspace
- **Name**: Auto-generated or `law-alz-central` (configurable)
- **Purpose**: Centralized logging and monitoring
- **Module**: Azure Verified Module

### Microsoft Sentinel
- **Enabled**: On Log Analytics Workspace
- **Data Connectors**: Azure AD, Azure Activity (configurable)
- **Purpose**: Security Information and Event Management

### Data Collection Rule
- **Name**: Auto-generated or `dcr-alz-central` (configurable)
- **Purpose**: Custom data ingestion rules
- **Kind**: Linux, Windows, or Agent

## References

- [ALZ Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator)
- [Azure Verified Module - Log Analytics Workspace](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace)
- [Microsoft Sentinel Documentation](https://docs.microsoft.com/azure/sentinel/)
- [Data Collection Rules Documentation](https://docs.microsoft.com/azure/azure-monitor/agents/data-collection-rule-overview)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## License

This module follows the same license as the ALZ Terraform Accelerator project.

