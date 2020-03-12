data "azurerm_subscription" "current" {
}

resource "random_string" "password" {
  length = 16
  special = true
  override_special = "/@£$!\\"
}

resource "azuread_application" "app" {
  name                       = "aksvnode"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "spn" {
  application_id               = azuread_application.app.application_id
  app_role_assignment_required = false
}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.spn.object_id
}

resource "azuread_service_principal_password" "password" {
  service_principal_id = azuread_service_principal.spn.id
  value                = random_string.password.result
  end_date_relative    = "9999h" # valid for 9999h
}

