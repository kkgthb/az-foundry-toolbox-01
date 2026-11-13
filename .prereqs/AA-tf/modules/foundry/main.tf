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

# TODO:  figure out how to make the actual toolbox and whatever onboarding stuff goes in it
# https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/toolbox
# Might have to figure out the equivalent of `azd ai toolbox create` 
# or run it with local-exec or something.
# Or maybe just deploy it w/ a separate `BB`-folder phase of setup, because 
# maybe it's more comparable to a webapp deployment or ORM than to infrastructure provisioning.
# Anyway, here's a `toolbox.yml` for use with `azd ai toolbox create` from 
# Google Search LLM summary:
# # name: my-enterprise-toolbox
# # description: Toolbox exposing an MCP server and skills in Microsoft Foundry
# # tools:
# #   - type: mcp
# #     server_label: my-custom-mcp-server
# #     server_url: https://your-mcp-server.example.com/mcp
# #     require_approval: never
# #     project_connection_id: my-mcp-connection
# #   - type: web_search
# #   - type: toolbox_search

# resource "msgraph_resource" "my_agent_id_blueprint" {
#   # TODO:  figure out if I'm actually going to want one of these
#   # (read more Anton Staykov)
#   # https://learn.microsoft.com/en-us/entra/agent-id/agent-blueprint
#   # It almost looks like maybe an azuread_application_federated_identity_credential 
#   # will need to get created, hanging off a Blueprint appreg ID, 
#   # to make a Blueprint trust 
#   # OIDC tokens from whatever principal ID 
#   # the GHCP desktop client has in the current tenant?
#   # But I could be way off base.
#   # No, that can't be right -- that'd be machine-to-machine, not OBO humans.
#   # Definitely more research needed.
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
