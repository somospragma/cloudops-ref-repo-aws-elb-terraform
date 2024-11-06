# variables.tf
variable "lb_config" {
    type = list(object({
      internal = bool
      load_balancer_type = string
      subnets = list(string)
      security_groups = list(string)
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
        certificate_arn = optional(string, null)
        ssl_policy = optional(string, "ELBSecurityPolicy-2016-08")
        default_action = object({
          type = string # "forward" o "redirect"
          target_group_key = optional(string)  # Requerido si type es "forward"
          redirect = optional(object({
            port = optional(string)
            protocol = optional(string)
            status_code = optional(string, "HTTP_301")
          }))
        })
      }))
      application_id = string
      ticket = string
      accessclass = string
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