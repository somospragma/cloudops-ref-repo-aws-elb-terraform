variable "lb_config" {
  description = "Mapa de configuraciones de balanceadores de carga"
  type = map(object({
    internal                   = bool
    load_balancer_type         = string
    drop_invalid_header_fields = bool
    idle_timeout               = number
    enable_deletion_protection = optional(bool, true)
    waf_arn                    = optional(string, "")
    subnets                    = list(string)
    security_groups            = list(string)
    additional_tags            = optional(map(string), {})  # Etiquetas específicas para este balanceador
    listeners = list(object({
      protocol                = string
      port                    = string
      certificate             = string
      default_target_group_id = string
      additional_tags         = optional(map(string), {})  # Etiquetas específicas para este listener
      rules = list(object({
        priority              = number
        target_application_id = string
        action = object({
          type = string
        })
        conditions = list(object({
          host_headers = optional(list(object({
            headers = list(string)
          })),[])
          path_patterns = optional(list(object({
            patterns = list(string)
          })),[])
        }))
      }))
    }))

    target_groups = list(object({
      target_application_id = string
      port                  = string
      protocol              = string
      vpc_id                = string
      target_type           = string
      healthy_threshold     = string
      interval              = string
      path                  = string
      unhealthy_threshold   = string
      matcher               = optional(string, "200")
      additional_tags       = optional(map(string), {})  # Etiquetas específicas para este grupo de destino
    }))

    application_id = string
  }))
  validation {
    condition = alltrue([
      for key, item in var.lb_config : alltrue([
        for listener in item.listeners : alltrue([
          for rule in listener.rules : alltrue([
            for condition in rule.conditions : 
              length(condition.host_headers) > 0 || length(condition.path_patterns) > 0
          ])
        ])
      ])
    ])
    error_message = "Para una definición de condición, alguno de los dos parámetros (host_headers o path_patterns) debe ser enviado."
  }
}

variable "project" {
  description = "Identificador del proyecto usado en la nomenclatura de recursos"
  type = string
}

variable "client" {
  description = "Identificador del cliente usado en la nomenclatura de recursos"
  type = string
}

variable "environment" {
  description = "Entorno de despliegue (ej., DEV, QA, PROD) usado en la nomenclatura de recursos"
  type = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], lower(var.environment))
    error_message = "El entorno debe ser uno de: dev, qa, pdn (case insensitive)."
  }
}

variable "tags" {
  description = "Mapa de etiquetas a aplicar a todos los recursos (NOTA: Esta variable está reservada para uso futuro. Actualmente, las etiquetas específicas deben definirse en additional_tags dentro de cada recurso)"
  type    = map(string)
  default = {}
}
