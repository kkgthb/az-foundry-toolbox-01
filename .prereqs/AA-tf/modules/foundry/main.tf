resource "random_string" "fnac_suffix" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_cognitive_account" "foundry_account" {
  name                = "fnac${random_string.fnac_suffix.result}"
  kind                = "AIServices"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku_name            = "F0"
  identity {
    type = "SystemAssigned"
  }
  local_auth_enabled = false
}

resource "azurerm_cognitive_account_project" "fnac_project" {
  name                 = "my-project"
  cognitive_account_id = azurerm_cognitive_account.foundry_account.id
  location             = var.resource_group.location
  description          = "My Azure Cognitive Services project"
  display_name         = "My first project"
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current_azurerm_config" {}

resource "azurerm_role_assignment" "me_as_foundry_user" {
  name                 = uuidv5("6ba7b810-9dad-11d1-80b4-00c04fd430c8", "${azurerm_cognitive_account_project.fnac_project.id}-${data.azurerm_client_config.current_azurerm_config.object_id}-Foundry User")
  scope                = azurerm_cognitive_account_project.fnac_project.id
  role_definition_name = "Foundry User"
  principal_id         = data.azurerm_client_config.current_azurerm_config.object_id
}

# resource "msgraph_resource" "my_agent_id_blueprint" {
#   # TODO:  figure out if I'm actually going to want one of these
#   path = "/beta/applications/${TODO_some_agent_appreg_client_id}/agentIdentityBlueprints"
#   body = jsonencode({
#     displayName = "MyAgentIdBlueprint"
#     description = "Blueprint for minting more Entra Agent IDs ephemerally"
#   })
# }

# TODO:  figure out if I want to make Anton Staykov proud by also granting 
# some Agent ID related principals "Foundry User."
# Of course, it'd help to have figured out what, exactly, those principals would be, 
# if the client would be a human via, say, GitHub Copilot driven desktop clients.
