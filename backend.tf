# Backend Configuration
# Following ALZ Terraform Accelerator patterns
# Azure Storage Account backend for remote state storage

terraform {
  backend "azurerm" {
    # Resource Group containing the Storage Account
    resource_group_name  = "rg-terraform-state"
    
    # Storage Account name (must be globally unique)
    storage_account_name = "stterraformstate"
    
    # Container name for storing state files
    container_name       = "tfstate"
    
    # State file key/path
    key                  = "avmsentinel.terraform.tfstate"
    
    # Optional: Enable state file encryption
    # encryption = true
    
    # Optional: Use Azure AD authentication
    # use_azuread_auth = true
    
    # Optional: Subscription ID (if different from default)
    # subscription_id = "your-subscription-id"
    
    # Optional: Tenant ID (if using Azure AD auth)
    # tenant_id = "your-tenant-id"
  }
}

