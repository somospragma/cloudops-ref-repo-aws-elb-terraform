###########################################
# Sample Variables
###########################################

variable "client" {
  type        = string
  description = "Client name or business unit identifier"
}

variable "project" {
  type        = string
  description = "Project name identifier"
}

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed (dev, qa, pdn)"
}

variable "lb_config" {
  type = map(object({
    internal                   = bool
    load_balancer_type         = string
    drop_invalid_header_fields = bool
    idle_timeout               = number
    enable_deletion_protection = optional(bool, true)
    waf_arn                    = optional(string, "")
    subnets                    = list(string)
    security_groups            = list(string)
    additional_tags            = optional(map(string), {})
    application_id             = string
  }))
  description = "Map of Load Balancer configurations"
}
