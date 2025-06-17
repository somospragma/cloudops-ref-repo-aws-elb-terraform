# Ejemplo de implementación avanzada del módulo AWS ELB

Este ejemplo muestra una implementación avanzada del módulo de AWS Elastic Load Balancer, configurando múltiples balanceadores de carga con configuraciones complejas e integración con otros servicios AWS.

## Estructura de archivos

- `main.tf`: Configuración principal que implementa el módulo ELB y recursos relacionados
- `providers.tf`: Configuración del proveedor AWS (no incluido, debe crearse)
- `terraform.tfvars.sample`: Ejemplo de variables (no incluido, debe crearse)

## Requisitos previos

Para ejecutar este ejemplo, necesitarás:

1. **Terraform**: Versión 1.0.0 o superior
2. **AWS CLI**: Configurado con credenciales válidas
3. **Permisos IAM**: Suficientes para crear y gestionar recursos de Load Balancer, Target Groups, WAF, Security Groups y ACM
4. **VPC existente**: Con etiquetas adecuadas para ser identificada por data sources
5. **Subnets existentes**: Con etiquetas adecuadas para ser identificadas por data sources

## Cómo usar este ejemplo

### 1. Preparación de variables

Crea un archivo `terraform.tfvars` basado en el ejemplo:

```hcl
client      = "tu-cliente"
service     = "tu-servicio"
environment = "dev"
```

### 2. Configura el proveedor AWS

Crea un archivo `providers.tf` con la configuración adecuada:

```hcl
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.service
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}
```

### 3. Inicializa Terraform

```bash
terraform init
```

### 4. Verifica el plan

```bash
terraform plan
```

### 5. Aplica la configuración

```bash
terraform apply
```

## Escenarios incluidos

### 1. Balanceador de carga público con WAF

Este ejemplo configura un ALB público con:
- Integración con AWS WAF para protección contra amenazas
- Reglas administradas por AWS para protección común
- Reglas basadas en tasas para prevenir ataques de fuerza bruta

### 2. Balanceador de carga interno para comunicación entre servicios

Configura un NLB interno para:
- Comunicación segura entre servicios dentro de la VPC
- Balanceo de carga TCP para servicios internos

### 3. Enrutamiento avanzado basado en host y path

Implementa reglas de enrutamiento complejas:
- Enrutamiento basado en host headers para diferentes dominios
- Enrutamiento basado en path patterns para diferentes servicios
- Combinación de ambos criterios para mayor precisión

### 4. Uso de data sources para recursos existentes

Utiliza data sources para:
- Obtener información de la VPC existente
- Identificar subnets públicas para el despliegue de balanceadores

### 5. Creación de recursos complementarios

Crea recursos adicionales necesarios:
- Security groups con reglas de entrada y salida adecuadas
- Certificados ACM para HTTPS
- Web ACL de WAF con reglas personalizadas

## Flujos de trabajo recomendados

### Implementación de nuevos servicios

Para añadir un nuevo servicio al balanceador existente:

1. Añade un nuevo target group en la configuración
2. Crea una nueva regla de listener con la prioridad adecuada
3. Aplica los cambios con `terraform apply`

### Actualización de reglas de seguridad

Para actualizar las reglas de WAF:

1. Modifica la configuración del módulo WAF
2. Aplica los cambios con `terraform apply`

## Integración con otros servicios AWS

### ECS

Para integrar con ECS:

```hcl
resource "aws_ecs_service" "example" {
  # Otras configuraciones...
  
  load_balancer {
    target_group_arn = module.load_balancer.target_group_info["api-payments"].target_arn
    container_name   = "api-container"
    container_port   = 8080
  }
}
```

### Auto Scaling Groups

Para integrar con ASG:

```hcl
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = module.load_balancer.target_group_info["api-default"].target_arn
}
```

## Solución de problemas comunes

### Error: certificate not found

Si recibes un error indicando que el certificado no se encuentra:
- Verifica que el ARN del certificado sea correcto
- Asegúrate de que el certificado esté en la misma región que el balanceador

### Error: security group rules

Si hay problemas con las reglas de security groups:
- Verifica que los security groups permitan el tráfico en los puertos configurados
- Asegúrate de que las reglas de salida permitan el tráfico a los destinos

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

**Nota importante**: La eliminación de los balanceadores de carga puede fallar si tienen habilitada la protección contra eliminación. En ese caso, primero debes desactivar esta protección.
