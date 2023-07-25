provider "azurerm" {
  features {}
}

# Create a new Resource Group
  resource "azurerm_resource_group" "example" {
  name     = "my-resource-group-name"
  location = "West US"
}

# Presentation Tier - Azure Web App
resource "azurerm_app_service_plan" "presentation_tier" {
  name                = "presentation-tier-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "presentation_tier" {
  name                = "presentation-tier-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.presentation_tier.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }
# Database Connection String
  app_settings = {
    "SOME_KEY" = "some-value"
  }
  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

# Application Tier - Azure Functions

resource "azurerm_storage_account" "example" {
  name                     = "functionsapptestsa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_app_service_plan" "example" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_function_app" "application_tier" {
  name                      = "application-tier-app"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  app_settings = {
    # Add any environment variables needed by your Azure Functions
    # For example, CONNECTION_STRING to connect to the database
    # "CONNECTION_STRING" = "your-database-connection-string"
  }
}

# Data Tier - Azure Cosmos DB

resource "azurerm_cosmosdb_sql_database" "data_tier" {
  name                = "my-database"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.data_tier.name
}

# Output the endpoints created for Azure Web APP and Azure Function APP to access the environment
output "presentation_tier_endpoint" {
  value = azurerm_app_service.presentation_tier.default_site_hostname
}

output "application_tier_endpoint" {
  value = azurerm_function_app.application_tier.default_hostname
}

output "data_tier_endpoint" {
  value = azurerm_cosmosdb_sql_database.data_tier.document_endpoint
}
