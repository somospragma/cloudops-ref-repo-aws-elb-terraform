###########################################
# Local Transformations for Sample
###########################################

# PC-IAC-026: Transformaciones e inyección de IDs dinámicos

locals {
  # Prefijo de gobernanza
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # PC-IAC-009: Transformar configuración inyectando IDs dinámicos
  # Si subnets o security_groups están vacíos, inyectar desde data sources
  lb_config_transformed = {
    for key, config in var.lb_config : key => merge(config, {
      # Inyectar subnet IDs si están vacíos
      subnets = length(config.subnets) > 0 ? config.subnets : data.aws_subnets.public.ids
      
      # Inyectar security group IDs si están vacíos (solo para ALB)
      security_groups = config.load_balancer_type == "application" && length(config.security_groups) == 0 ? 
        [data.aws_security_group.alb.id] : 
        config.security_groups
    })
  }
}
