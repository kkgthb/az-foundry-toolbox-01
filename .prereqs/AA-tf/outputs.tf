output "resource_group_name" {
  value = azurerm_resource_group.my_resource_group.name
}

output "fnac" {
  value = module.foundry.fnac
}

output "fnac_project" {
  value = module.foundry.fnac_project
}
