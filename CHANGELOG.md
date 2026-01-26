# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-26

### Cambiado
- **BREAKING CHANGE**: Módulo refactorizado para crear SOLO Load Balancers (ALB/NLB)
- Target Groups, Listeners y Listener Rules movidos a módulo separado
- Aplicadas reglas PC-IAC de gobernanza (15 reglas implementadas)
- Estructura de variables simplificada (solo configuración de LB)
- Outputs granulares con información específica del LB

### Añadido
- Cumplimiento con PC-IAC-001 (18 archivos obligatorios)
- Nomenclatura estándar según PC-IAC-003
- Validaciones de variables según PC-IAC-002
- Directorio `sample/` con ejemplo funcional (PC-IAC-026)
- Archivo `versions.tf` separado (PC-IAC-006)
- Hardenizado de seguridad por defecto (PC-IAC-020)
- Cross-zone load balancing habilitado
- Integración con WAF para ALB
- Documentación completa en README.md

### Eliminado
- Recursos de Target Groups (ahora en módulo separado)
- Recursos de Listeners (ahora en módulo separado)
- Recursos de Listener Rules (ahora en módulo separado)
- Directorio `examples/` (reemplazado por `sample/`)

### Características de Seguridad
- Cross-zone load balancing habilitado por defecto
- Drop invalid header fields para ALB
- Protección contra eliminación configurable
- Integración con WAF para ALB públicos

## [1.0.0] - 2025-06-17

### Añadido
- Implementación inicial del módulo de AWS ELB
- Soporte para Application Load Balancers (ALB) y Network Load Balancers (NLB)
- Configuración de target groups con health checks personalizables
- Definición de listeners con certificados SSL/TLS
- Creación de reglas de enrutamiento basadas en host headers y path patterns
- Integración con AWS WAF para seguridad mejorada
- Nomenclatura estandarizada de recursos y etiquetado

