###########################################
############## LB Module ##################
###########################################

module "alb" {
  source = "../../"

  providers = {
    aws.project = aws.alias01              #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  client        = var.client
  project       = var.project
  application   = var.application
  environment   = var.environment

  # LB configuration
  lb_config = var.lb_config
}