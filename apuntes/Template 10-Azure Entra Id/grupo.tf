resource "azuread_group" "engineering" {
  display_name     = "Education Department"
  security_enabled = true
}

resource "azuread_group_member" "education" {
  for_each = { for key, user in azuread_user.users : key => user if user.department == "Education" } # toma el key valor(nombre) y user (recibe todo el obejtio del usuario es decir su object id, etc) crea la usuaior por pasos 
  #{ for user in azuread_user.users : user.mail_nickname => user if user.department == "Education" } tengo que crear primero al usuario y luego desplegar 

  group_object_id  = azuread_group.engineering.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "managers" {
  display_name     = "Education - Managers"
  security_enabled = true
}

resource "azuread_group_member" "managers" {
  for_each = { for key, user in azuread_user.users : key => user if user.job_title == "Manager" }

  group_object_id  = azuread_group.managers.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "engineers" {
  display_name     = "Education - Engineers"
  security_enabled = true
}

resource "azuread_group_member" "engineers" {
  for_each = { for key, user in azuread_user.users : key => user if user.job_title == "Engineer" }

  group_object_id  = azuread_group.engineers.object_id
  member_object_id = each.value.object_id
}
