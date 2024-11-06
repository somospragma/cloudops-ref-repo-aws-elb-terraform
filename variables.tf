# En variables.tf
variable "lb_config" {
  type = list(object({
    internal = bool
    load_balancer_type = string
    subnets = list(string)
    security_groups = list(string)
    application_id = string
    accessclass = string
    target_groups = list(object({
      target_application_id = string
      port = string
      protocol = string
      vpc_id = string
      target_type = string
      healthy_threshold = string
      interval = string
      path = string
      unhealthy_threshold = string
    }))
    listeners = list(object({
      port = number
      protocol = string
      certificate_arn = optional(string)
      ssl_policy = optional(string, "ELBSecurityPolicy-2016-08")  # Valor por defecto añadido
      default_action = object({
        type = string
        target_group_key = optional(string)
        redirect = optional(object({
          port = string
          protocol = string
          status_code = string
        }))
      })
    }))
  }))
}

variable "service" {
  type = string
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}


variable "project" {
    description = "Nombre de Projecto"
    type = string
}