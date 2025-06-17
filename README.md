# Módulo Terraform: AWS Elastic Load Balancer

## Descripción
Este módulo Terraform permite la creación y configuración de balanceadores de carga AWS (tanto Application Load Balancers como Network Load Balancers) con características avanzadas que incluyen grupos de destino, oyentes, reglas de oyentes e integración con WAF. El módulo está diseñado para implementar configuraciones de balanceadores de carga siguiendo las mejores prácticas y gobernanza de AWS.

Para ver el historial de cambios, consulta el [CHANGELOG.md](./CHANGELOG.md).

Se recomienda fijar la versión del módulo en implementaciones de producción:
```hcl
module "elb" {
  source = "git::https://github.com/somospragma/modulos/cloudops-ref-repo-aws-elb-terraform.git?ref=v1.0.0"
  # Resto de la configuración...
}
```

## Diagrama de Arquitectura
```
                                  +----------------+
                                  |                |
                                  |   AWS WAF      |
                                  |                |
                                  +--------+-------+
                                           |
                                           v
+--------+    HTTPS    +----------------+    HTTP    +----------------+
|        |------------>|                |----------->|                |
| Client |             | Load Balancer  |            | Target Groups  |
|        |<------------|                |<-----------|                |
+--------+             +----------------+            +----------------+
                              |
                              | Health Checks
                              v
                       +----------------+
                       |                |
                       | CloudWatch     |
                       |                |
                       +----------------+
```

## Características
- ✅ Creación de múltiples balanceadores de carga con diferentes configuraciones
- ✅ Soporte para Application Load Balancers (ALB) y Network Load Balancers (NLB)
- ✅ Configuración de grupos de destino con health checks personalizables
- ✅ Definición de oyentes con certificados SSL/TLS
- ✅ Creación de reglas de enrutamiento complejas basadas en host headers y path patterns
- ✅ Integración con AWS WAF para seguridad mejorada
- ✅ Nomenclatura estandarizada de recursos y etiquetado
- ✅ Soporte para balanceo de carga entre zonas
- ✅ Protección contra eliminación configurable

## Estructura del Módulo
El módulo consiste en los siguientes archivos:

* **main.tf**: Contiene la definición principal de los recursos de AWS Load Balancer, incluyendo balanceadores de carga, grupos de destino, oyentes y reglas de oyentes.
* **variables.tf**: Define todas las variables de entrada que el módulo acepta para configuración.
* **outputs.tf**: Define los valores de salida que el módulo proporciona después del despliegue.
* **providers.tf**: Define los requisitos de proveedores y sus configuraciones.
* **locals.tf**: Contiene las transformaciones y cálculos locales para facilitar el manejo de datos.
* **data.tf**: Contiene recursos de datos que pueden ser utilizados por el módulo.
* **examples/**: Directorio con ejemplos de implementación del módulo.

## Implementación y Configuración

### Requisitos Técnicos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

### Provider Configuration

El módulo requiere la configuración de un proveedor AWS con alias:

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "elb"
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.project
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}

module "elb" {
  source = "path/to/module"
  
  providers = {
    aws.elb = aws.elb
  }
  
  # Resto de la configuración...
}
```

### Configuración del Backend

Se recomienda utilizar un backend remoto para almacenar el estado de Terraform:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "elb/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Convenciones de nomenclatura

El módulo utiliza la siguiente convención de nomenclatura para los recursos:

```
{client}-{environment}-{application_id}-{resource_type}-{index}
```

Por ejemplo:
- `cliente-dev-api-alb-1`: Application Load Balancer
- `dev-target-api-payments`: Target Group
- `dev-listener-api-443`: Listener

### Estrategia de Etiquetado

El sistema de etiquetado se implementa en tres niveles:

1. **Etiquetas Transversales**: Definidas a nivel del proveedor AWS usando `default_tags`
2. **Etiquetas Comunes**: Definidas en la variable `tags` del módulo
3. **Etiquetas Específicas del Recurso**: Definidas en la propiedad `additional_tags` de cada recurso

Las etiquetas se aplican siguiendo esta jerarquía, donde las más específicas tienen prioridad sobre las más generales.

### Recursos Gestionados

| Nombre | Tipo | Descripción |
|--------|------|-------------|
| aws_lb | Recurso | Balanceador de carga (ALB o NLB) |
| aws_lb_target_group | Recurso | Grupo de destino para el balanceador |
| aws_lb_listener | Recurso | Oyente para el balanceador |
| aws_lb_listener_rule | Recurso | Regla de enrutamiento para el oyente |
| aws_wafv2_web_acl_association | Recurso | Asociación de WAF con el balanceador |

### Parámetros de Entrada

| Nombre | Descripción | Tipo | Default | Requerido |
|--------|-------------|------|---------|:--------:|
| lb_config | Mapa de configuraciones de balanceadores de carga | `map(object)` | n/a | sí |
| project | Identificador del proyecto usado en la nomenclatura de recursos | `string` | n/a | sí |
| client | Identificador del cliente usado en la nomenclatura de recursos | `string` | n/a | sí |
| environment | Entorno de despliegue (ej., DEV, QA, PROD) usado en la nomenclatura de recursos | `string` | n/a | sí |
| tags | Mapa de etiquetas (NOTA: Esta variable está reservada para uso futuro. Actualmente, las etiquetas específicas deben definirse en additional_tags dentro de cada recurso) | `map(string)` | `{}` | no |

### Estructura de Configuración

La variable `lb_config` tiene la siguiente estructura:

```hcl
map(object({
  internal                   = bool           # Si el balanceador es interno
  load_balancer_type         = string         # Tipo de balanceador ("application" o "network")
  drop_invalid_header_fields = bool           # Si se deben descartar campos de encabezado inválidos
  idle_timeout               = number         # Tiempo de espera en segundos
  enable_deletion_protection = optional(bool) # Si se debe habilitar la protección contra eliminación
  waf_arn                    = optional(string) # ARN del WAF a asociar con el balanceador
  subnets                    = list(string)   # Lista de IDs de subnets
  security_groups            = list(string)   # Lista de IDs de grupos de seguridad
  additional_tags            = optional(map(string), {}) # Etiquetas específicas para este balanceador
  
  listeners = list(object({
    protocol                = string         # Protocolo del oyente (HTTP, HTTPS, TCP, TLS)
    port                    = string         # Puerto del oyente
    certificate             = string         # ARN del certificado SSL/TLS
    default_target_group_id = string         # ID del grupo de destino por defecto
    additional_tags         = optional(map(string), {}) # Etiquetas específicas para este oyente
    
    rules = list(object({
      priority              = number         # Prioridad de la regla (número menor = mayor prioridad)
      target_application_id = string         # ID de la aplicación de destino
      action = object({
        type = string                        # Tipo de acción (forward)
      })
      conditions = list(object({
        host_headers = optional(list(object({
          headers = list(string)             # Lista de host headers
        })),[])
        path_patterns = optional(list(object({
          patterns = list(string)            # Lista de patrones de ruta
        })),[])
      }))
    }))
  }))

  target_groups = list(object({
    target_application_id = string           # ID de la aplicación de destino
    port                  = string           # Puerto del grupo de destino
    protocol              = string           # Protocolo del grupo de destino
    vpc_id                = string           # ID de la VPC
    target_type           = string           # Tipo de destino (instance, ip, lambda)
    healthy_threshold     = string           # Número de verificaciones de salud exitosas consecutivas
    interval              = string           # Intervalo de verificación de salud en segundos
    path                  = string           # Ruta de verificación de salud
    unhealthy_threshold   = string           # Número de verificaciones de salud fallidas consecutivas
    matcher               = optional(string) # Códigos HTTP a usar al verificar respuestas exitosas
    additional_tags       = optional(map(string), {}) # Etiquetas específicas para este grupo de destino
  }))

  application_id = string                    # Identificador de la aplicación
}))
```

### Valores de Salida

| Nombre | Descripción |
|--------|-------------|
| load_balancer_info | Lista de información de balanceadores de carga incluyendo ARN, nombre DNS y ID de zona |
| target_group_info | Mapa de información de grupos de destino por ID de aplicación |

### Ejemplos de Uso

Ejemplo básico:

```hcl
module "load_balancer" {
  source      = "path/to/module"
  client      = "cliente"
  project     = "api"
  environment = "dev"
  
  providers = {
    aws.elb = aws.principal
  }
  
  # Las etiquetas específicas se definen en additional_tags dentro de cada recurso
  lb_config = {
    "api-lb" = {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 60
      enable_deletion_protection = false
      waf_arn                    = ""
      subnets                    = ["subnet-12345678", "subnet-87654321"]
      security_groups            = ["sg-12345678"]
      application_id             = "api"
      additional_tags            = {
        Department = "Engineering"
        Owner      = "DevOps"
        Environment = "Development"
        Project     = "API Platform"
      }
      
      listeners = [
        {
          protocol                = "HTTPS"
          port                    = "443"
          certificate             = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef12-3456-7890-abcd-ef1234567890"
          default_target_group_id = "api-default"
          additional_tags         = {}
          
          rules = [
            {
              priority              = 100
              target_application_id = "api-payments"
              action = {
                type = "forward"
              }
              conditions = [
                {
                  host_headers = [
                    {
                      headers = ["api.example.com"]
                    }
                  ]
                  path_patterns = [
                    {
                      patterns = ["/payments/*"]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
      
      target_groups = [
        {
          target_application_id = "api-default"
          port                  = "8080"
          protocol              = "HTTP"
          vpc_id                = "vpc-12345678"
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
          additional_tags       = {}
        },
        {
          target_application_id = "api-payments"
          port                  = "8081"
          protocol              = "HTTP"
          vpc_id                = "vpc-12345678"
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/payments/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
          additional_tags       = {
            Service = "Payments"
          }
        }
      ]
    }
  }
}
```

Para ejemplos más avanzados, consulta el directorio [examples](./examples).

## Escenarios de Uso Comunes

### Balanceador de carga público con HTTPS

```hcl
lb_config = {
  "public-alb" = {
    internal                   = false
    load_balancer_type         = "application"
    drop_invalid_header_fields = true
    idle_timeout               = 60
    enable_deletion_protection = true
    # Resto de la configuración...
  }
}
```

### Balanceador de carga interno para microservicios

```hcl
lb_config = {
  "internal-alb" = {
    internal                   = true
    load_balancer_type         = "application"
    drop_invalid_header_fields = true
    idle_timeout               = 60
    enable_deletion_protection = true
    # Resto de la configuración...
  }
}
```

### Network Load Balancer para tráfico TCP

```hcl
lb_config = {
  "tcp-nlb" = {
    internal                   = false
    load_balancer_type         = "network"
    drop_invalid_header_fields = false
    idle_timeout               = 60
    enable_deletion_protection = true
    # Resto de la configuración...
    
    listeners = [
      {
        protocol                = "TCP"
        port                    = "80"
        certificate             = ""
        default_target_group_id = "tcp-default"
        # Resto de la configuración...
      }
    ]
  }
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- Los Application Load Balancers pueden manejar miles de conexiones por segundo
- Para cargas de trabajo muy altas, considera usar múltiples balanceadores o Network Load Balancers
- El balanceo de carga entre zonas está habilitado por defecto para mejor distribución del tráfico

### Limitaciones y Restricciones

- Los Network Load Balancers no soportan la integración con WAF
- Los balanceadores de carga tienen cuotas de servicio que pueden necesitar ser aumentadas para implementaciones grandes
- La protección contra eliminación debe desactivarse manualmente antes de eliminar un balanceador

### Costos y Optimización

- Los costos de los balanceadores de carga dependen del tipo, horas de funcionamiento y datos procesados
- Considera usar balanceadores internos para tráfico entre servicios para reducir costos
- Monitorea el uso para optimizar el tamaño y tipo de balanceador

### Recomendaciones de Implementación

- Usa subnets en múltiples zonas de disponibilidad para alta disponibilidad
- Implementa health checks adecuados para cada servicio
- Configura timeouts apropiados según la naturaleza de tus aplicaciones
- Habilita logs de acceso para auditoría y solución de problemas

## Seguridad y Cumplimiento

### Consideraciones de seguridad

- Usa HTTPS para todo el tráfico externo
- Configura security groups restrictivos para los balanceadores
- Implementa WAF para protección contra amenazas web comunes
- Habilita la eliminación de campos de encabezado inválidos

### Mejores Prácticas Implementadas

- Balanceo de carga entre zonas para alta disponibilidad
- Protección contra eliminación para prevenir eliminaciones accidentales
- Integración con WAF para seguridad mejorada
- Eliminación de campos de encabezado inválidos
- Nomenclatura estandarizada y etiquetado consistente

### Lista de Verificación de Cumplimiento

- [x] Nomenclatura de recursos conforme al estándar
- [x] Etiquetas obligatorias aplicadas a todos los recursos
- [x] Validaciones para garantizar configuraciones correctas
- [x] Soporte para HTTPS con certificados SSL/TLS
- [x] Configuración de health checks para monitoreo
- [x] Integración con WAF para protección contra amenazas
- [x] Balanceo de carga entre zonas para alta disponibilidad
- [x] Protección contra eliminación configurable

## Observaciones

- Este módulo está diseñado para ser flexible y adaptarse a diferentes casos de uso
- Para balanceadores de carga internos, asegúrate de que las subnets tengan rutas adecuadas
- La integración con WAF es opcional pero altamente recomendada para balanceadores públicos
- Considera implementar redirección de HTTP a HTTPS para mejorar la seguridad

> "Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción."
