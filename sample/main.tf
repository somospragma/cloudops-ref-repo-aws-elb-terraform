###########################################
# Sample Module Invocation
###########################################

# PC-IAC-026: Invocación del módulo padre con configuración transformada

module "load_balancers" {
  source = "../"  # Módulo padre
  
  # PC-IAC-005: Inyección de provider
  providers = {
    aws.project = aws.principal
  }
  
  # PC-IAC-002: Variables de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment
  
  # PC-IAC-026: Consumir configuración transformada desde locals
  lb_config = local.lb_config_transformed
}
