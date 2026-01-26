# Ejemplo de Uso del Módulo ELB

Este directorio contiene un ejemplo funcional de cómo usar el módulo de referencia de ELB (Load Balancer).

## Estructura

El ejemplo sigue el patrón de transformación definido en PC-IAC-026:

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
```

## Prerrequisitos

- Terraform >= 1.0.0
- AWS CLI configurado con credenciales válidas
- Acceso a una cuenta AWS con permisos para crear Load Balancers
- VPC y subnets existentes
- Security groups existentes (para ALB)

## Uso

1. Copiar `terraform.tfvars` y ajustar los valores según tu entorno:
   ```bash
   cp terraform.tfvars terraform.tfvars.local
   vim terraform.tfvars.local
   ```

2. Inicializar Terraform:
   ```bash
   terraform init
   ```

3. Revisar el plan:
   ```bash
   terraform plan
   ```

4. Aplicar la configuración:
   ```bash
   terraform apply
   ```

## Limpieza

Para eliminar los recursos creados:

```bash
terraform destroy
```

## Notas

- Este ejemplo crea un Application Load Balancer público
- El WAF es opcional y puede dejarse vacío
- Para Network Load Balancers, dejar `security_groups` vacío
- Los Target Groups y Listeners se gestionan en un módulo separado
