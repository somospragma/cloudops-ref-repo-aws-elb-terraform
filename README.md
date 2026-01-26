# Módulo de Referencia: AWS ELB (Elastic Load Balancer)

## Descripción

Este módulo de referencia facilita la creación y gestión de balanceadores de carga AWS (Application Load Balancers y Network Load Balancers) siguiendo las mejores prácticas de seguridad y gobernanza definidas en las reglas PC-IAC.

**IMPORTANTE:** Este módulo crea únicamente el Load Balancer. Los Target Groups, Listeners y Listener Rules se gestionan en el módulo complementario `cloudops-ref-repo-aws-elb-listener-terraform`.

### Estrategia de Separación

Este módulo forma parte de una estrategia de separación de responsabilidades:

- **Módulo Transversal** (este módulo): Crea la infraestructura base compartida (Load Balancer)
- **Módulo Funcionalidad** (`cloudops-ref-repo-aws-elb-listener-terraform`): Crea configuraciones específicas por servicio (Target Groups, Listeners, Rules)

Esta separación permite:
- ✅ Ciclos de vida independientes
- ✅ Múltiples equipos trabajando en paralelo
- ✅ Menor riesgo en cambios
- ✅ Escalabilidad mejorada

### Características Principales

- ✅ Creación de Application Load Balancers (ALB)
- ✅ Creación de Network Load Balancers (NLB)
- ✅ Integración con AWS WAF para seguridad mejorada
- ✅ Nomenclatura estándar según PC-IAC-003
- ✅ Sistema de etiquetado con merge de tags
- ✅ Protección contra eliminación configurable
- ✅ Cross-zone load balancing habilitado por defecto
- ✅ Drop invalid header fields para ALB
- ✅ Soporte para balanceadores internos y públicos

## Estructura del Módulo

```
cloudops-ref-repo-aws-elb-terraform/
├── .gitignore
├── CHANGELOG.md
├── README.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── sample/
    ├── README.md
    ├── data.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    └── variables.tf
```

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

## Providers

| Nombre | Alias | Descripción |
|--------|-------|-------------|
| aws | aws.project | Provider inyectado desde el módulo raíz |

## Recursos Creados

| Tipo | Descripción |
|------|-------------|
| `aws_lb` | Load Balancer (ALB o NLB) |
| `aws_wafv2_web_acl_association` | Asociación de WAF con ALB (opcional) |

## Uso del Módulo

### Ejemplo Básico - ALB Público

```hcl
module "alb_public" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-elb-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "platform"
  environment = "dev"
  
  lb_config = {
    "public" = {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 60
      enable_deletion_protection = false
      waf_arn                    = ""
      subnets                    = ["subnet-12345678", "subnet-87654321"]
      security_groups            = ["sg-12345678"]
      application_id             = "platform-api"
      additional_tags = {
        team        = "platform"
        cost-center = "engineering"
      }
    }
  }
}
```

### Ejemplo - ALB con WAF

```hcl
module "alb_with_waf" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-elb-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "ecommerce"
  environment = "pdn"
  
  lb_config = {
    "frontend" = {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 120
      enable_deletion_protection = true
      waf_arn                    = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/example/a1b2c3d4"
      subnets                    = ["subnet-11111111", "subnet-22222222"]
      security_groups            = ["sg-11111111"]
      application_id             = "web-frontend"
      additional_tags = {
        compliance = "PCI-DSS"
        owner      = "WebTeam"
      }
    }
  }
}
```

### Ejemplo - NLB Interno

```hcl
module "nlb_internal" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-elb-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "backend"
  environment = "pdn"
  
  lb_config = {
    "internal" = {
      internal                   = true
      load_balancer_type         = "network"
      drop_invalid_header_fields = false
      idle_timeout               = 350
      enable_deletion_protection = true
      waf_arn                    = ""  # WAF no aplica para NLB
      subnets                    = ["subnet-33333333", "subnet-44444444"]
      security_groups            = []  # NLB no usa security groups
      application_id             = "backend-services"
      additional_tags = {
        tier = "backend"
      }
    }
  }
}
```

### Ejemplo - Múltiples Load Balancers

```hcl
module "load_balancers" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-elb-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "platform"
  environment = "pdn"
  
  lb_config = {
    "public-alb" = {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 60
      enable_deletion_protection = true
      waf_arn                    = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/public/a1b2c3d4"
      subnets                    = ["subnet-pub-1", "subnet-pub-2"]
      security_groups            = ["sg-public"]
      application_id             = "public-api"
      additional_tags            = {}
    }
    "internal-nlb" = {
      internal                   = true
      load_balancer_type         = "network"
      drop_invalid_header_fields = false
      idle_timeout               = 350
      enable_deletion_protection = true
      waf_arn                    = ""
      subnets                    = ["subnet-priv-1", "subnet-priv-2"]
      security_groups            = []
      application_id             = "internal-services"
      additional_tags            = {}
    }
  }
}
```

## Inputs

| Nombre | Descripción | Tipo | Requerido | Default |
|--------|-------------|------|-----------|---------|
| `client` | Nombre del cliente o unidad de negocio | `string` | Sí | - |
| `project` | Nombre del proyecto | `string` | Sí | - |
| `environment` | Ambiente de despliegue (dev, qa, pdn) | `string` | Sí | - |
| `lb_config` | Mapa de configuraciones de load balancers | `map(object)` | Sí | - |

### Estructura de `lb_config`

```hcl
map(object({
  internal                   = bool           # Si el balanceador es interno
  load_balancer_type         = string         # "application" o "network"
  drop_invalid_header_fields = bool           # Descartar headers inválidos (solo ALB)
  idle_timeout               = number         # Timeout en segundos (1-4000)
  enable_deletion_protection = optional(bool) # Protección contra eliminación
  waf_arn                    = optional(string) # ARN del WAF (solo ALB)
  subnets                    = list(string)   # IDs de subnets
  security_groups            = list(string)   # IDs de security groups (solo ALB)
  additional_tags            = optional(map(string)) # Etiquetas adicionales
  application_id             = string         # ID de la aplicación
}))
```

## Outputs

| Nombre | Descripción | Tipo |
|--------|-------------|------|
| `load_balancer_info` | Información completa de los load balancers | `map(object)` |
| `load_balancer_arns` | Mapa de ARNs por clave | `map(string)` |
| `load_balancer_dns_names` | Mapa de DNS names por clave | `map(string)` |
| `load_balancer_zone_ids` | Mapa de zone IDs por clave | `map(string)` |

## Nomenclatura

Los load balancers siguen el patrón de nomenclatura estándar (PC-IAC-003):

```
{client}-{project}-{environment}-{alb|nlb}-{key}
```

**Ejemplos:**
- `pragma-platform-dev-alb-public`
- `pragma-backend-pdn-nlb-internal`

## Seguridad y Cumplimiento

### Hardenizado de Seguridad (PC-IAC-020)

Este módulo implementa las siguientes medidas de seguridad por defecto:

- ✅ **Cross-zone load balancing**: Habilitado por defecto para alta disponibilidad
- ✅ **Drop invalid header fields**: Habilitado para ALB (seguridad)
- ✅ **Protección contra eliminación**: Configurable (true por defecto)
- ✅ **Integración con WAF**: Soporte para ALB públicos
- ✅ **Security groups**: Requeridos para ALB, no para NLB

### Validaciones

El módulo incluye validaciones para:
- Longitud de nombres de variables de gobernanza
- Valores válidos para `environment` (dev, qa, pdn, prod)
- Valores válidos para `load_balancer_type` (application, network)
- Rango válido para `idle_timeout` (1-4000 segundos)
- Longitud del nombre generado (máximo 32 caracteres)

## Cumplimiento de Reglas PC-IAC

Este módulo cumple con las siguientes reglas de gobernanza:

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | 18 archivos obligatorios (10 raíz + 8 sample/) |
| PC-IAC-002 | Variables | Validaciones, tipos explícitos, uso de `map(object)` |
| PC-IAC-003 | Nomenclatura Estándar | Construcción en `locals.tf` con patrón estándar |
| PC-IAC-004 | Etiquetas (Tagging) | Merge de Name y additional_tags |
| PC-IAC-005 | Providers | Alias `aws.project` consumido desde el Root |
| PC-IAC-006 | Versiones | `required_version >= 1.0.0`, provider >= 4.31.0 |
| PC-IAC-007 | Outputs | Outputs granulares (ARNs, DNS names, zone IDs) |
| PC-IAC-009 | Tipos y Conversiones | Uso de `optional()`, validaciones de tipo |
| PC-IAC-010 | For_Each | Uso de `for_each` con `map` para estabilidad |
| PC-IAC-011 | Data Sources | Data sources solo en el Root (sample/) |
| PC-IAC-012 | Locals | Centralización de nomenclatura |
| PC-IAC-020 | Hardenizado | Cross-zone LB, drop invalid headers |
| PC-IAC-023 | Responsabilidad Única | Solo crea Load Balancers |
| PC-IAC-026 | Patrón sample/ | Flujo tfvars → locals → main |

## Decisiones de Diseño

### Separación de Responsabilidades

El módulo se enfoca únicamente en crear el Load Balancer, delegando Target Groups y Listeners a un módulo separado. Esto permite:

- Ciclos de vida independientes
- Menor riesgo en cambios
- Múltiples equipos trabajando en paralelo
- Escalabilidad mejorada

### Uso de `map(object)` en lugar de `list(object)`

Se utiliza `map(object)` para la variable `lb_config` (PC-IAC-002) para garantizar la estabilidad del estado de Terraform.

### Cross-Zone Load Balancing

Habilitado por defecto para mejor distribución del tráfico y alta disponibilidad.

### Protección contra Eliminación

Por defecto está habilitada (`enable_deletion_protection = true`). Debe desactivarse manualmente antes de destruir el recurso.

## Consideraciones Importantes

### Dependencias con Módulo Listener

Este módulo debe usarse en conjunto con `cloudops-ref-repo-aws-elb-listener-terraform`:

1. **Primero**: Desplegar este módulo (crea el Load Balancer)
2. **Segundo**: Desplegar el módulo listener (crea TG, Listeners, Rules)

### Security Groups

- **ALB**: Requiere security groups
- **NLB**: No usa security groups (lista vacía)

### WAF Integration

- Solo disponible para Application Load Balancers
- Network Load Balancers no soportan WAF

### Limitaciones

- Los Network Load Balancers no soportan WAF
- Los Network Load Balancers no usan security groups
- El módulo no crea Target Groups ni Listeners (usar módulo complementario)
- Idle timeout solo aplica para ALB (1-4000 segundos)

## Ejemplo Completo

Para un ejemplo funcional completo, consulta el directorio `sample/` que incluye:
- Configuración de ejemplo en `terraform.tfvars`
- Inyección dinámica de subnet IDs y security group IDs
- Múltiples load balancers con diferentes configuraciones
- Integración con WAF

## Versionamiento

Este módulo sigue [Semantic Versioning](https://semver.org/). Consulta el [CHANGELOG.md](./CHANGELOG.md) para ver el historial de cambios.

## Próximos Pasos

Después de desplegar este módulo:

1. Usar el output `load_balancer_info` para obtener el ARN del LB
2. Desplegar el módulo `cloudops-ref-repo-aws-elb-listener-terraform`
3. Configurar Target Groups y Listeners en el módulo complementario
4. Registrar targets en los Target Groups

## Contribución

Para contribuir a este módulo, por favor:
1. Asegúrate de que todos los cambios cumplan con las reglas PC-IAC
2. Actualiza el CHANGELOG.md
3. Ejecuta `terraform fmt` y `terraform validate`
4. Actualiza la documentación si es necesario

## Licencia

Copyright © 2025 Pragma S.A.

## Soporte

Para soporte o preguntas, contacta al equipo de CloudOps.
