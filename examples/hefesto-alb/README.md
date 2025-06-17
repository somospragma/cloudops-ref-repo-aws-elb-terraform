# Ejemplo de implementación del balanceador de carga Hefesto

Este ejemplo muestra cómo implementar un balanceador de carga para la plataforma Hefesto (Backstage) utilizando el módulo de AWS ELB. La configuración replica un balanceador de carga existente en el entorno de desarrollo.

## Estructura de archivos

- `main.tf`: Configuración principal que implementa el módulo ELB con la configuración del balanceador Hefesto
- `variables.tf`: Definición de variables utilizadas en el ejemplo
- `outputs.tf`: Salidas que muestran información sobre los recursos creados
- `terraform.tfvars.sample`: Ejemplo de archivo de variables

## Requisitos previos

Para ejecutar este ejemplo, necesitarás:

1. **Terraform**: Versión 1.0.0 o superior
2. **AWS CLI**: Configurado con el perfil `pra_idp_dev`
3. **Permisos IAM**: Suficientes para crear y gestionar recursos de Load Balancer
4. **Recursos de red**: VPC, subnets y security groups existentes (los IDs en el ejemplo son de recursos reales)
5. **Certificado SSL/TLS**: Un certificado válido en AWS Certificate Manager (el ARN en el ejemplo es de un certificado real)

## Cómo usar este ejemplo

### 1. Preparación de variables

Crea un archivo `terraform.tfvars` basado en el ejemplo:

```bash
cp terraform.tfvars.sample terraform.tfvars
```

### 2. Inicializa Terraform

```bash
terraform init
```

### 3. Verifica el plan

```bash
terraform plan
```

### 4. Aplica la configuración

```bash
terraform apply
```

## Arquitectura implementada

Este ejemplo implementa un Application Load Balancer (ALB) con las siguientes características:

1. **Balanceador de carga público** con acceso desde Internet
2. **Listener HTTPS** en el puerto 443 con un certificado SSL/TLS
3. **Dos target groups**:
   - `core`: Para el servicio principal de Backstage (puerto 7007)
   - `delivery`: Para los servicios de scaffolder y techdocs (puerto 7008)
4. **Regla de enrutamiento** que dirige las solicitudes a `/api/scaffolder/*` y `/api/techdocs/*` al target group `delivery`
5. **Health checks** configurados para verificar la ruta `/.backstage/health/v1/liveness`

## Diagrama de arquitectura

```
                                  +----------------+
                                  |                |
                Internet -------> | ALB (HTTPS:443)| 
                                  |                |
                                  +--------+-------+
                                           |
                                           v
                      +-------------------+-----------------+
                      |                                     |
                      v                                     v
          +-----------------------+            +-----------------------+
          | Target Group: core    |            | Target Group: delivery|
          | (HTTP:7007)           |            | (HTTP:7008)           |
          +-----------------------+            +-----------------------+
          | Default route         |            | /api/scaffolder/*     |
          |                       |            | /api/techdocs/*       |
          +-----------------------+            +-----------------------+
```

## Notas importantes

1. Este ejemplo utiliza IDs de recursos reales de la cuenta AWS con el perfil `pra_idp_dev`. Si deseas implementarlo en otro entorno, deberás actualizar estos IDs.

2. La configuración del balanceador de carga se ha extraído de un balanceador existente (`pragma-hefesto-dev-alb-bs-01`).

3. No se ha configurado ninguna asociación de WAF ya que el balanceador original no tenía ninguna.

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```
