provider "azurerm" {
  features {}
}

// Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

// Create app service plan
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

//Create app service
resource "azurerm_app_service" "appservice" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    linux_fx_version = "DOTNETCORE|3.0"
  }

  // backup configuration
  backup {
    name = var.backup_name
    storage_account_url = var.storage_account_url
    schedule {
        frequency_interval = var.frequency_interval
        frequency_unit = var.frequency_unit
        
        
    }
  }
}

//deployment slots for app service
resource "azurerm_app_service_slot" "staging" {
  name                = "staging"
  app_service_name    = azurerm_app_service.appservice.name
  resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    location = azurerm_resource_group.rg.location
}

//create deployment slot for app service : name = "production"
resource "azurerm_app_service_slot" "production" {
  name                = "production"
  app_service_name    = azurerm_app_service.appservice.name
  resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    location = azurerm_resource_group.rg.location
}

//create deployment slot for app service : name = "Dev"
resource "azurerm_app_service_slot" "dev" {
  name                = "dev"
  app_service_name    = azurerm_app_service.appservice.name
  resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    location = azurerm_resource_group.rg.location
}

//create auto scale settings for app service
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_app_service.appservice.id

  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_app_service.appservice.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
   //rule for decrease
    rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = azurerm_app_service.appservice.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "LessThan"
            threshold          = 30
        }
    
        scale_action {
            direction = "Decrease"
            type      = "ChangeCount"
            value     = 1
            cooldown  = "PT5M"
        }
    }
  }
}

//create budget for resource group
resource "azurerm_consumption_budget" "budget" {
  name                = "budget"
  resource_group_name = azurerm_resource_group.rg.name
  amount              = 800
  time_grain          = "Monthly"
  time_period         = "PT1M"
  notifications {
    enabled = true
    contact_email = var.email
    contact_role = "Owner"
    threshold = 70
    }
}


