resource "azurerm_resource_group" "rg1" {
  location = "eastus"
  name     = "dev-rg-1"
}
data "azurerm_subscription" "main" {
  subscription_id = "4ffc4be1-d195-4e71-aa14-07e148042f6c"
}
resource "azuread_user" "user1" {
  display_name        = "infra Dev"
  user_principal_name = "infra_dev@devoteymgmail.onmicrosoft.com"
  password              = "P@ssw0rd123"
  force_password_change = true
}

resource "azuread_user" "user2" {
  display_name        = "App Dev"
  user_principal_name = "app_dev@devoteymgmail.onmicrosoft.com"
  password              = "P@ssw0rd234"
  force_password_change = true
}

resource "azuread_group" "Group1" {
  display_name     = "SRE"
  members = [
    azuread_user.user1.object_id,
    azuread_user.user2.object_id]
}
resource "azurerm_role_assignment" "role_attachment" {
  principal_id = azuread_group.Group1.object_id
  scope        = data.azurerm_subscription.main.id
  role_definition_name = "Reader"
}