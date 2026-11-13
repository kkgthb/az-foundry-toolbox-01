output "fnac" {
  description = "Foundry resource details"
  value = {
    id       = azurerm_cognitive_account.foundry_account.id
    endpoint = azurerm_cognitive_account.foundry_account.endpoint
  }
}

output "fnac_project" {
  description = "Foundry project resource details"
  value = {
    id        = azurerm_cognitive_account_project.fnac_project.id
    endpoints = azurerm_cognitive_account_project.fnac_project.endpoints
  }
}
