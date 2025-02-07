###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
  description = "Project name"
}

variable "application" {
  type = string  
  description = "Application name"
}

###########################################
############# LB variables ################
###########################################

variable "lb_config" {
  type = list(object({
    internal = bool
    load_balancer_type = string
    subnets = list(string)
    security_groups = list(string)
    application = string
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
      timeout = string
    }))
    listeners = list(object({
      port = number
      protocol = string
      certificate_arn = optional(string)
      ssl_policy = optional(string, "ELBSecurityPolicy-2016-08")
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
  description = <<EOF
    - internal: (bool) If true, the LB will be internal. Defaults to false.
    - load_balancer_type: (string) Type of load balancer to create. Possible values are application, gateway, or network. The default value is application. 
    - subnets: (list(string)) List of subnet IDs to attach to the LB. For Load Balancers of type network subnets can only be added, deleting a subnet for load balancers of type network will force a recreation of the resource.
    - security_groups: (list(string)) List of security group IDs to assign to the LB. Only valid for Load Balancers of type application or network. For load balancers of type network security groups cannot be added if none are currently present, and cannot all be removed once added. If either of these conditions are met, this will force a recreation of the resource.
    - application: (string) Application name.
    - target_groups: (list(object))
      - target_application_id: (string) PENDING
      - port: (string) Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
      - protocol: (string) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip, or alb. Does not apply when target_type is lambda.
      - vpc_id: (string) Identifier of the VPC in which to create the target group. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda.
      - target_type: (string) Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance.
      - healthy_threshold: (string) Number of consecutive health check successes required before considering a target healthy. The range is 2-10. Defaults to 3.
      - interval: (string) Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300. For lambda target groups, it needs to be greater than the timeout of the underlying lambda. Defaults to 30.
      - path: (string) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS.
      - unhealthy_threshold: (string) Number of consecutive health check failures required before considering a target unhealthy. The range is 2-10. Defaults to 3.
      - timeout: (string) Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2-120 seconds. The timeout must be less than the interval value.

    - listeners: (list(object))
      - port: (number) Port on which the load balancer is listening. Not valid for Gateway Load Balancers.
      - protocol: (string) Protocol for connections from clients to the load balancer. For Application Load Balancers, valid values are HTTP and HTTPS, with a default of HTTP. For Network Load Balancers, valid values are TCP, TLS, UDP, and TCP_UDP. Not valid to use UDP or TCP_UDP if dual-stack mode is enabled. Not valid for Gateway Load Balancers.
      - certificate_arn: (optional, string) ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. For adding additional SSL certificates
      - ssl_policy: (optinal, string) Name of the SSL Policy for the listener. Required if protocol is HTTPS or TLS. Default is ELBSecurityPolicy-2016-08.
      - default_action: (object)
        - type: (string) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc.
        - target_group_key: (optional, string) ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead. Can be specified with forward but ARNs must match.
        - redirect: (optional, object)
          - port: (string) Port. Specify a value from 1 to 65535 or #{port}. Defaults to
          - protocol: (string) Protocol. Valid values are HTTP, HTTPS, or #{protocol}. Defaults to #{protocol}.
          - status_code: (string) HTTP redirect code. The redirect is either permanent (HTTP_301) or temporary (HTTP_302).
  EOF
}
