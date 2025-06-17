provider "aws" {
  region = "us-east-1"
  profile = "pra_idp_dev"
  alias  = "principal"
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.project
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}

module "hefesto_load_balancer" {
  source      = "../../"
  client      = var.client
  project     = var.project
  environment = var.environment
  
  providers = {
    aws.elb = aws.principal
  }
  
  lb_config = {
    "hefesto-bs" = {
      internal                   = false  # internet-facing
      load_balancer_type         = "application"
      drop_invalid_header_fields = false  # según los atributos
      idle_timeout               = 60     # según los atributos
      enable_deletion_protection = false  # según los atributos
      waf_arn                    = ""     # no hay WAF asociado
      subnets                    = [
        "subnet-01bc32f0ec46e2db0",  # us-east-1a
        "subnet-0be7f3a353d7b4347"   # us-east-1b
      ]
      security_groups            = ["sg-00ab18a5dc6fa4eca"]
      application_id             = "bs"
      additional_tags            = {
        Name = "pragma-hefesto-dev-alb-bs-01"
      }
      
      listeners = [
        {
          protocol                = "HTTPS"
          port                    = "443"
          certificate             = "arn:aws:acm:us-east-1:008971642453:certificate/b8b4a552-e28f-448a-93dd-e1897e28bad7"
          default_target_group_id = "core"
          additional_tags         = {}
          
          rules = [
            {
              priority              = 1
              target_application_id = "delivery"
              action = {
                type = "forward"
              }
              conditions = [
                {
                  host_headers = []
                  path_patterns = [
                    {
                      patterns = ["/api/scaffolder/*", "/api/techdocs/*"]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
      
      target_groups = [
        {
          target_application_id = "core"
          port                  = "7007"
          protocol              = "HTTP"
          vpc_id                = "vpc-082d1e1ec5f1b3ac4"
          target_type           = "ip"
          healthy_threshold     = "5"
          interval              = "30"
          path                  = "/.backstage/health/v1/liveness"
          unhealthy_threshold   = "2"
          matcher               = "200"
          additional_tags       = {
            Name = "pragma-idp-hefesto-tg-core"
          }
        },
        {
          target_application_id = "delivery"
          port                  = "7008"
          protocol              = "HTTP"
          vpc_id                = "vpc-082d1e1ec5f1b3ac4"
          target_type           = "ip"
          healthy_threshold     = "5"
          interval              = "30"
          path                  = "/.backstage/health/v1/liveness"
          unhealthy_threshold   = "2"
          matcher               = "200"
          additional_tags       = {
            Name = "pragma-idp-hefesto-tg-delivery"
          }
        }
      ]
    }
  }
  
  tags = {
    Application = "Backstage"
  }
}
