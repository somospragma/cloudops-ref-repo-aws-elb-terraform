# Ejemplo de implementación básica del módulo AWS ELB

Este ejemplo muestra una implementación básica del módulo de AWS Elastic Load Balancer, configurando un Application Load Balancer (ALB) con un listener HTTPS y reglas de enrutamiento.

## Estructura de archivos

- `main.tf`: Configuración principal que implementa el módulo ELB
- `providers.tf`: Configuración del proveedor AWS (no incluido, debe crearse)
- `terraform.tfvars.sample`: Ejemplo de variables (no incluido, debe crearse)

## Requisitos previos

Para ejecutar este ejemplo, necesitarás:

1. **Terraform**: Versión 1.0.0 o superior
2. **AWS CLI**: Configurado con credenciales válidas
3. **Permisos IAM**: Suficientes para crear y gestionar recursos de Load Balancer, Target Groups y WAF
4. **Recursos de red**: VPC, subnets y security groups existentes (los IDs en el ejemplo son ficticios)
5. **Certificado SSL/TLS**: Un certificado válido en AWS Certificate Manager (el ARN en el ejemplo es ficticio)

## Cómo usar este ejemplo

### 1. Preparación de variables

Crea un archivo `terraform.tfvars` basado en el ejemplo:

```hcl
client      = "tu-cliente"
service     = "tu-servicio"
environment = "dev"
```

### 2. Actualiza los IDs de recursos

Modifica el archivo `main.tf` para usar IDs reales de tus recursos:
- Subnets: Reemplaza `subnet-12345678` y `subnet-87654321` con tus IDs de subnets
- Security Groups: Reemplaza `sg-12345678` con tu ID de security group
- VPC: Reemplaza `vpc-12345678` con tu ID de VPC
- Certificado ACM: Reemplaza el ARN del certificado con uno válido

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

### 6. Verifica los recursos creados

Una vez completada la implementación, verifica que se hayan creado los siguientes recursos:
- Application Load Balancer
- Target Groups
- Listener HTTPS
- Reglas de enrutamiento

## Escenarios incluidos

### Balanceador de carga público con enrutamiento basado en path

Este ejemplo configura un ALB público que enruta el tráfico a diferentes servicios basándose en la ruta de la URL:
- Solicitudes a `/payments/*` se enrutan al target group `api-payments`
- Otras solicitudes se enrutan al target group por defecto `api-default`

### Configuración de health checks

Cada target group tiene configurados health checks personalizados:
- Target group `api-default`: Health check en la ruta `/health`
- Target group `api-payments`: Health check en la ruta `/payments/health`

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

**Nota**: Asegúrate de que no haya recursos dependientes antes de eliminar la infraestructura.
