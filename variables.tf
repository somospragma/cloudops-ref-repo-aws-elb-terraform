###########################################
########## Common Variables ###############
###########################################

variable "client" {
  type        = string
  description = "Client name or business unit identifier"
  
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "Client name must be between 1 and 10 characters"
  }
}

variable "project" {
  type        = string
  description = "Project name identifier"
  
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "Project name must be between 1 and 15 characters"
  }
}

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed (dev, qa, pdn)"
  
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn, prod"
  }
}

###########################################
######### Load Balancer Variables #########
###########################################

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
  
  description = <<-EOF
    Map of Load Balancer configurations. Key is the load balancer identifier.
    
    - internal: (bool) Whether the load balancer is internal or internet-facing
    - load_balancer_type: (string) Type of load balancer. Valid values: application, network
    - drop_invalid_header_fields: (bool) Drop invalid header fields (ALB only)
    - idle_timeout: (number) Idle timeout in seconds (1-4000)
    - enable_deletion_protection: (optional, bool) Enable deletion protection. Defaults to true
    - waf_arn: (optional, string) ARN of the WAF Web ACL to associate (ALB only)
    - subnets: (list(string)) List of subnet IDs
    - security_groups: (list(string)) List of security group IDs (ALB only, empty for NLB)
    - additional_tags: (optional, map(string)) Additional tags to apply to the load balancer
    - application_id: (string) Application identifier for tagging
  EOF
  
  validation {
    condition     = length(var.lb_config) > 0
    error_message = "At least one load balancer configuration must be provided"
  }
  
  validation {
    condition = alltrue([
      for key, lb in var.lb_config :
      contains(["application", "network"], lb.load_balancer_type)
    ])
    error_message = "load_balancer_type must be either 'application' or 'network'"
  }
  
  validation {
    condition = alltrue([
      for key, lb in var.lb_config :
      lb.idle_timeout >= 1 && lb.idle_timeout <= 4000
    ])
    error_message = "idle_timeout must be between 1 and 4000 seconds"
  }
  
  validation {
    condition = alltrue([
      for key, lb in var.lb_config :
      length(join("-", [var.client, var.project, var.environment, lb.load_balancer_type == "application" ? "alb" : "nlb", key])) <= 32
    ])
    error_message = "The generated load balancer name exceeds the 32 character limit. Please use shorter keys in lb_config"
  }
}
