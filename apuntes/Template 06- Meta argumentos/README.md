# Template 06 – Meta-argumentos y Expresiones en Terraform

<img width="1582" height="976" alt="Esquema Meta-argumentos" src="https://github.com/user-attachments/assets/691580a7-7560-47aa-8b17-e13b108fafc7" />

---

## ¿Qué son los Meta-argumentos?

En Terraform, los **meta-argumentos** son parámetros especiales reservados por el lenguaje HCL que se pueden usar dentro de cualquier bloque `resource` o `module`. 

> [!NOTE]
> No configuran características propias del recurso en la nube (como el tamaño de una VM o el nombre de un grupo de recursos), sino que **modifican el comportamiento de Terraform respecto a cómo, cuántas veces, en qué orden y con qué ciclo de vida se despliega ese recurso**.

Existen **5 meta-argumentos oficiales**:
1. `depends_on`
2. `count`
3. `for_each`
4. `provider`
5. `lifecycle`

Además, en este template se aborda la expresión **`for`**, utilizada para transformar colecciones en las salidas (`outputs`).

---

## 1. `depends_on` – Dependencia explícita

Por defecto, Terraform analiza el código y deduce automáticamente las dependencias (dependencia implícita). Por ejemplo, si una Subnet usa `azurerm_resource_group.rg.name`, Terraform sabe que primero debe crear el Resource Group.

Sin embargo, hay casos donde un recurso necesita que otro exista primero sin que haya una referencia directa de atributos. Para eso sirve `depends_on`:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "example-rg"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  location            = "westeurope"
  resource_group_name = "example-rg"

  # Le forzamos a esperar a que el Resource Group esté 100% creado
  depends_on = [
    azurerm_resource_group.rg
  ]
}
```

---

## 2. `count` – Multiplicador numérico (Array)

Permite crear $N$ instancias del mismo recurso usando un número entero. Cada instancia se indexa numéricamente desde `0` hasta `count - 1` usando `count.index`.

### Ejemplo en este laboratorio ([main.tf](file:///e:/Terrafom/apuntes/Template%2006-%20Meta%20argumentos/main.tf)):
```hcl
resource "azurerm_storage_account" "example" {
  count = length(var.nombre_storage) # Longitud de la lista (ej: 2)

  name                     = var.nombre_storage[count.index] # [0], [1]...
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### Identificadores generados en el estado:
* `azurerm_storage_account.example[0]`
* `azurerm_storage_account.example[1]`

> [!CAUTION]
> ### El gran problema de `count` ("Shift Problem"):
> Si tienes `["storageA", "storageB", "storageC"]` y eliminas `"storageA"` de la lista:
> 1. Lo que era el índice `[1]` (`storageB`) ahora pasa a ser el índice `[0]`.
> 2. Lo que era el índice `[2]` (`storageC`) pasa a ser el `[1]`.
> 3. Terraform intentará **destruir y recrear** recursos que solo cambiaron de posición en la lista. ¡En bases de datos o cuentas de almacenamiento esto causaría pérdida de datos!

---

## 3. `for_each` – Multiplicador por Claves Únicas

`for_each` soluciona las limitaciones de `count`. En lugar de basarse en números de índice, crea una instancia por cada elemento de un **`map`** o un **`set(string)`**.

Cada recurso queda vinculado a su clave identificadora fija:
* `each.key`: la clave o identificador único del elemento actual.
* `each.value`: el valor asociado al elemento actual.

### A. Uso con `set(string)` (Implementación activa en [main.tf](file:///e:/Terrafom/apuntes/Template%2006-%20Meta%20argumentos/main.tf)):
```hcl
# variables.tf
variable "for_each_nombre_storage" {
  type    = set(string)
  default = ["templatestorage12", "templatestorage13"]
}

# main.tf
resource "azurerm_storage_account" "example" {
  for_each = var.for_each_nombre_storage

  name                     = each.value # o each.key (en un set son iguales)
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### Identificadores generados en el estado:
* `azurerm_storage_account.example["templatestorage12"]`
* `azurerm_storage_account.example["templatestorage13"]`

Si eliminas `"templatestorage12"`, Terraform **únicamente destruye ese recurso específico**, sin tocar a los demás.

### B. ¿Por qué `set(string)` y NO `list(string)`?
* **Regla de Terraform**: `for_each` solo acepta `map` o `set(string)`.
* **Motivo**: Las listas permiten elementos duplicados (`["storage1", "storage1"]`). Como Terraform necesita nombres únicos para su árbol de estado, exige un `set` (conjunto sin duplicados) o un mapa clave-valor.
* **Conversor rápido**: Si tienes una lista y quieres usarla con `for_each`, conviértela al vuelo con la función `toset()`:
  ```hcl
  for_each = toset(var.mi_lista)
  ```

### C. Uso con `map(string)`:
```hcl
variable "subnets" {
  type = map(string)
  default = {
    web = "10.0.1.0/24"
    db  = "10.0.2.0/24"
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key     # "web", "db"
  address_prefixes     = [each.value] # "10.0.1.0/24", "10.0.2.0/24"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.example.name
}
```

---

## 4. Tabla Comparativa: `count` vs `for_each`

| Característica | `count` | `for_each` |
| :--- | :--- | :--- |
| **Entrada aceptada** | Número entero (`number`) | `set(string)` o `map(string)` |
| **Identificador en estado** | Índice numérico: `[0]`, `[1]` | Clave/Nombre: `["clave"]` |
| **Variables de iteración** | `count.index` | `each.key`, `each.value` |
| **Resistencia a borrados intermedios** | ❌ Pobre (provoca recreaciones en cascada) | ✅ Alta (solo afecta al recurso eliminado) |
| **Cuándo usarlo** | Habilitar/deshabilitar un recurso condicional (`count = var.crear ? 1 : 0`) o copias totalmente idénticas. | Cuando cada recurso tiene una identidad o configuración propia (subredes, discos, VMs, cuentas). |

---

## 5. Expresión `for` (Bucles en Outputs y Transformaciones)

> [!IMPORTANT]
> No confundir el meta-argumento **`for_each`** (para crear recursos) con la expresión **`for`** (para recorrer y transformar datos, comúnmente en `outputs` o variables locales).

Cuando creas recursos con `for_each`, el resultado es un mapa de instancias. Para consultar sus datos en [output.tf](file:///e:/Terrafom/apuntes/Template%2006-%20Meta%20argumentos/output.tf) se usan comprensiones:

### Salida como Lista `[...]`:
Recorre cada cuenta de almacenamiento y devuelve una lista solo con los nombres:
```hcl
output "storage_name" {
  value = [for i in azurerm_storage_account.example : i.name]
}
# Resultado: ["templatestorage12", "templatestorage13"]
```

### Salida como Mapa `{...}`:
Genera un diccionario relacionando cada nombre con su ID:
```hcl
output "storage_ids_map" {
  value = { for k, v in azurerm_storage_account.example : k => v.id }
}
```

### Salida con condición (`if`):
```hcl
output "solo_storage12" {
  value = [for i in azurerm_storage_account.example : i.name if i.name == "templatestorage12"]
}
```

---

## 6. `provider` – Selección de Instancia o Alias de Proveedor

Permite que un recurso específico use una configuración alternativa de proveedor (por ejemplo, para desplegar recursos en múltiples suscripciones o regiones distintas en el mismo proyecto):

```hcl
# Proveedor por defecto
provider "azurerm" {
  features {}
}

# Proveedor alternativo con alias
provider "azurerm" {
  alias           = "suscripcion_produccion"
  features        = {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

# Se crea en la suscripción por defecto
resource "azurerm_resource_group" "dev_rg" {
  name     = "dev-rg"
  location = "westeurope"
}

# Se crea en la suscripción de producción
resource "azurerm_resource_group" "prod_rg" {
  provider = azurerm.suscripcion_produccion
  name     = "prod-rg"
  location = "northeurope"
}
```

---

## 7. `lifecycle` – Control del Ciclo de Vida del Recurso

Permite alterar las reglas estándar de cómo Terraform gestiona los cambios y destrucciones de recursos:

```hcl
resource "azurerm_storage_account" "critical" {
  # ... config ...

  lifecycle {
    # 1. Evita caídas de servicio: crea primero el recurso nuevo antes de destruir el viejo
    create_before_destroy = true

    # 2. Protección contra errores humanos: impide que 'terraform destroy' borre el recurso
    prevent_destroy = true

    # 3. Ignora cambios en propiedades modificadas fuera de Terraform (ej: Azure Portal o CI/CD)
    ignore_changes = [
      tags,
      account_tier
    ]

    # 4. Fuerza la recreación si otro recurso especificado cambia
    # replace_triggered_by = [azurerm_resource_group.example.id]
  }
}
```

---

## 8. Comandos de Verificación para este Template

```bash
# Formatear y validar código
terraform fmt
terraform validate

# Ver recursos que se van a crear (deben mostrarse con su clave [templatestorage...])
terraform plan

# Aplicar los cambios
terraform apply --auto-approve

# Inspeccionar cómo quedaron indexados en el estado
terraform state list
```
