# Provider Configuration
# Following ALZ Terraform Accelerator patterns

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
  # Azure API Provider for resources not yet supported by azurerm provider
  # Used for Data Collection Rules
}

