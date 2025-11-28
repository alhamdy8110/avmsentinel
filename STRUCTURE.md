# Terraform Structure - ALZ Log Analytics with Sentinel and DCR

This document describes the Terraform structure following the [ALZ Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator/tree/main/templates/platform_landing_zone) patterns.

## Directory Structure

```
avmsentinel/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── providers.tf              # Provider configuration (azurerm, azapi)
├── locals.tf                  # Local values and naming conventions
├── dev.tfvars                 # Development environment variables
├── staging.tfvars            # Staging environment variables
├── README.md                  # Comprehensive documentation
└── STRUCTURE.md               # This file
```

## File Descriptions

### main.tf
Contains the main infrastructure resources:
- Management Group
- Subscription
- Resource Group
- **Log Analytics Workspace** (Azure Verified Module)
- **Microsoft Sentinel** (onboarding and data connectors)
- **Data Collection Rule** (using azapi provider)
- Application Insights
- Key Vault
- Network Security Group

### variables.tf
All input variables organized by resource type:
- General configuration (location, environment, tags)
- Management Group variables
- Subscription variables
- Resource Group variables
- **Log Analytics variables** (retention, SKU, quota, network access)
- **Sentinel variables** (enablement, data connectors, CMK)
- **Data Collection Rule variables** (sources, flows, kind)
- Application Insights variables
- Key Vault variables
- NSG variables

### outputs.tf
All output values:
- Management Group ID
- Subscription ID
- Resource Group information
- **Log Analytics outputs** (ID, customer ID, shared keys)
- **Sentinel outputs** (workspace ID, data connectors)
- **Data Collection Rule outputs** (ID, name, endpoint)
- Application Insights outputs
- Key Vault outputs
- NSG outputs
- Backend configuration

### providers.tf
Provider configuration:
- `azurerm` provider (~> 3.0) - Main Azure provider
- `azapi` provider (~> 1.0) - For Data Collection Rules (not fully supported in azurerm)

### locals.tf
Local values following ALZ naming conventions:
- Resource naming patterns
- Common tags
- Resource-specific tags
- Auto-generated names

### *.tfvars
Environment-specific variable files:
- `dev.tfvars` - Development environment
- `staging.tfvars` - Staging environment
- `prod.tfvars` - Production environment (create as needed)

## Key Components

### Log Analytics Workspace
- **Module**: `Azure/avm-res-operationalinsights-workspace/azurerm`
- **Version**: `~> 0.4`
- **Features**: Retention, SKU, daily quota, network access control

### Microsoft Sentinel
- **Resource**: `azurerm_sentinel_log_analytics_workspace_onboarding`
- **Data Connectors**: 
  - Azure Active Directory
  - Azure Activity
- **Extensible**: Easy to add custom analytics rules

### Data Collection Rule
- **Provider**: `azapi` (Azure API Provider)
- **Resource Type**: `Microsoft.Insights/dataCollectionRules@2022-06-01`
- **Features**: 
  - Performance counters
  - Windows Event Logs
  - Syslog
  - Extensions
- **Role Assignment**: Automatic role assignment for DCR to write to LAW

## Naming Conventions

Following ALZ best practices:
- **Log Analytics**: `law-{env}-{location}-{hash}`
- **Sentinel**: `sentinel-{env}-{location}`
- **Data Collection Rule**: `dcr-{env}-{location}-{hash}`
- **Resource Groups**: `rg-{purpose}-{env}`

## Dependencies

```
Management Group
    ↓
Subscription
    ↓
Resource Group
    ↓
Log Analytics Workspace
    ↓
    ├──→ Sentinel Onboarding
    │       ↓
    │       └──→ Sentinel Data Connectors
    │
    └──→ Data Collection Rule
            ↓
            └──→ Role Assignment (DCR → LAW)
```

## Best Practices

1. **Use Azure Verified Modules**: All core resources use AVM modules
2. **Environment Separation**: Separate tfvars files for each environment
3. **Tagging**: Consistent tagging strategy across all resources
4. **Naming**: Auto-generated names with predictable patterns
5. **Security**: Network access controls and role-based access
6. **Monitoring**: Comprehensive logging and monitoring setup
7. **Documentation**: Detailed README and inline comments

## References

- [ALZ Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Microsoft Sentinel Documentation](https://docs.microsoft.com/azure/sentinel/)
- [Data Collection Rules](https://docs.microsoft.com/azure/azure-monitor/agents/data-collection-rule-overview)

