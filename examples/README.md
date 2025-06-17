# AWS Load Balancer Module Examples

Este directorio contiene ejemplos de implementación del módulo de AWS Load Balancer.

## Estructura de ejemplos

- [**basic/**](./basic/): Ejemplo básico de implementación de un Application Load Balancer (ALB) con configuración mínima.
- [**advanced/**](./advanced/): Ejemplo avanzado que muestra múltiples configuraciones de Load Balancer, integración con WAF y configuraciones de enrutamiento complejas.

## Ejemplo básico

El ejemplo básico muestra cómo implementar un Application Load Balancer (ALB) con:
- Un listener HTTPS en el puerto 443
- Dos target groups para diferentes servicios
- Reglas de enrutamiento basadas en host headers y path patterns
- Configuración básica de seguridad

Para ejecutar este ejemplo:

```bash
cd basic
terraform init
terraform plan
terraform apply
```

## Ejemplo avanzado

El ejemplo avanzado muestra una implementación más completa que incluye:
- Un Application Load Balancer (ALB) público para la API de pagos
- Un Network Load Balancer (NLB) interno para comunicación entre servicios
- Integración con AWS WAF para protección contra amenazas
- Múltiples listeners y target groups
- Reglas de enrutamiento complejas
- Uso de datos de infraestructura existente (VPC, subnets)
- Creación de recursos adicionales (security groups, certificados ACM)

Para ejecutar este ejemplo:

```bash
cd advanced
terraform init
terraform plan
terraform apply
```

## Notas importantes

1. **Valores de ejemplo**: Los ejemplos utilizan valores ficticios para IDs de recursos como subnets, VPCs y security groups. En un entorno real, deberás reemplazar estos valores con los IDs de tus propios recursos.

2. **Certificados SSL/TLS**: Los ejemplos incluyen referencias a certificados SSL/TLS. En un entorno real, deberás proporcionar ARNs de certificados válidos o crear nuevos certificados.

3. **Integración con WAF**: El ejemplo avanzado muestra cómo integrar el Load Balancer con AWS WAF. Asegúrate de tener los permisos necesarios para crear y gestionar recursos de WAF.

4. **Personalización**: Estos ejemplos están diseñados para ser puntos de partida. Personaliza las configuraciones según tus necesidades específicas.

5. **Costos**: Recuerda que la implementación de estos ejemplos en AWS generará costos. Asegúrate de entender los costos asociados antes de aplicar los ejemplos en un entorno de producción.
