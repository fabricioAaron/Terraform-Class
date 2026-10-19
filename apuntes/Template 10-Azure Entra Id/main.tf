data "azuread_domains" "name" { # este bloque sirve para obtener informacion sobre los dominios de azure ad
  only_initial = true           # Para devolver solo el dominio inicial, que es el dominio de inquilino principal de Azure Active Directory
}

locals {
  domain_name = data.azuread_domains.name.domains.0.domain_name
  #value = data.azuread_domains.name.domains.*.domain_name # devuelve el nombre del dominio
  users = csvdecode(file("users.csv")) # convierte el archivo csv en una lista de mapas
}

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user } # lo tranforma en formato clave => valor
  user_principal_name = format("%s.%s@%s",                         # el formato es en 3 argumentos el @ significa que ese valor lo tomará como fijo
    lower(each.value.first_name),
    lower(each.value.last_name),
  local.domain_name)

  password = format("%s%s%s!", #en este formato lo que hace es que pondra ! en todo lo que despligue 
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
  length(each.value.first_name))

  display_name          = "${each.value.first_name} ${each.value.last_name}"
  force_password_change = true
  department            = each.value.department
  job_title             = each.value.job_title
}

output "domain_name" {
  value = local.domain_name
}
output "users" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}


