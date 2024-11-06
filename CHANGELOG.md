# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-18

### Añadido
- Lanzamiento inicial del módulo VPC.
- Creación de VPC con bloque CIDR configurable.
- Soporte para creación de subredes públicas y privadas.
- Configuración de Internet Gateway (IGW) opcional.
- Configuración de NAT Gateway opcional.
- Implementación de tablas de rutas para cada subred.
- Soporte para rutas personalizadas.
- Configuración del grupo de seguridad predeterminado de la VPC.
- Estructura del proyecto con carpetas `modules/vpc` y `sample`.
- README.md completo con descripción del módulo, estructura, inputs y outputs.
- Ejemplo de uso funcional en la carpeta `sample`.

### Cambiado
- N/A

### Eliminado
- N/A

### Corregido
- N/A

### Seguridad
- Configuración inicial de mínimos de seguridad.