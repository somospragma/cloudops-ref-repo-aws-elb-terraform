###########################################
# Sample Configuration for ELB Module
###########################################

# Variables de gobernanza
client      = "pragma"
project     = "platform"
environment = "dev"

# Configuración de Load Balancers
# Nota: Los valores de subnets y security_groups se dejan vacíos y se llenarán automáticamente desde data sources
lb_config = {
  "public-alb" = {
    internal                   = false
    load_balancer_type         = "application"
    drop_invalid_header_fields = true
    idle_timeout               = 60
    enable_deletion_protection = false
    waf_arn                    = ""  # Opcional: ARN del WAF Web ACL
    
    # Se llenarán automáticamente desde data sources
    subnets         = []
    security_groups = []
    
    application_id = "platform-api"
    
    # Tags adicionales específicos del balanceador
    additional_tags = {
      team        = "platform"
      cost-center = "engineering"
      tier        = "frontend"
    }
  }
  
  "internal-nlb" = {
    internal                   = true
    load_balancer_type         = "network"
    drop_invalid_header_fields = false
    idle_timeout               = 350
    enable_deletion_protection = false
    waf_arn                    = ""  # WAF no aplica para NLB
    
    # Se llenarán automáticamente desde data sources
    subnets         = []
    security_groups = []  # NLB no usa security groups
    
    application_id = "backend-services"
    
    additional_tags = {
      team = "backend"
      tier = "backend"
    }
  }
}
