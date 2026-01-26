###########################################
# Local Values - Transformaciones y nomenclatura
###########################################

locals {
  # PC-IAC-003: Prefijo de gobernanza para nomenclatura estándar
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # PC-IAC-003: Generar nombres estandarizados para los load balancers
  # Formato: {client}-{project}-{environment}-{alb|nlb}-{key}
  lb_names = {
    for key, lb in var.lb_config : key => join("-", [
      var.client,
      var.project,
      var.environment,
      lb.load_balancer_type == "application" ? "alb" : "nlb",
      key
    ])
  }
}
