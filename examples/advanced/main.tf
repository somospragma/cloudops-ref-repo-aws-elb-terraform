provider "aws" {
  region = "us-east-1"
}

# Obtener información de la VPC y subredes existentes
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}

# Crear un grupo de seguridad para el ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "alb-security-group"
  }
}

# Crear un certificado ACM para HTTPS (en un entorno real, esto ya existiría)
resource "aws_acm_certificate" "cert" {
  domain_name       = "api.example.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Crear un WAF Web ACL para proteger el ALB
module "waf" {
  source       = "../../terraform-aws-ops-repo-waf-001"
  client       = "banesco"
  functionality = "api"
  environment  = "dev"
  
  waf_config = [
    {
      application   = "payment-api"
      scope         = "REGIONAL"
      description   = "WAF for Payment API"
      default_allow = false
      
      rules = [
        {
          name     = "AWSManagedRulesCommonRuleSet"
          priority = 0
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesCommonRuleSet"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "RateBasedRule"
          priority = 1
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 1000
              evaluation_window_sec = 300
              aggregate_key_type = "IP"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  ]
}

# Implementar el módulo de Load Balancer con múltiples configuraciones
module "load_balancer" {
  source      = "../../"
  client      = "banesco"
  service     = "api"
  environment = "dev"
  
  lb_config = [
    # Configuración del ALB principal para la API de pagos
    {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 60
      enable_deletion_protection = true
      waf_arn                    = module.waf.waf_info["payment-api"]
      subnets                    = data.aws_subnets.public.ids
      security_groups            = [aws_security_group.alb_sg.id]
      application_id             = "payment-api"
      
      listeners = [
        # Listener HTTPS
        {
          protocol                = "HTTPS"
          port                    = "443"
          certificate             = aws_acm_certificate.cert.arn
          default_target_group_id = "api-default"
          
          rules = [
            # Regla para el servicio de pagos
            {
              priority              = 100
              target_application_id = "api-payments"
              action = {
                type = "forward"
              }
              conditions = [
                {
                  host_headers = [
                    {
                      headers = ["api.example.com"]
                    }
                  ]
                  path_patterns = [
                    {
                      patterns = ["/payments/*"]
                    }
                  ]
                }
              ]
            },
            # Regla para el servicio de autenticación
            {
              priority              = 200
              target_application_id = "api-auth"
              action = {
                type = "forward"
              }
              conditions = [
                {
                  host_headers = [
                    {
                      headers = ["api.example.com"]
                    }
                  ]
                  path_patterns = [
                    {
                      patterns = ["/auth/*"]
                    }
                  ]
                }
              ]
            }
          ]
        },
        # Listener HTTP (para redirección a HTTPS en un caso real)
        {
          protocol                = "HTTP"
          port                    = "80"
          certificate             = ""
          default_target_group_id = "api-default"
          
          rules = []
        }
      ]
      
      target_groups = [
        # Target group por defecto
        {
          target_application_id = "api-default"
          port                  = "8080"
          protocol              = "HTTP"
          vpc_id                = data.aws_vpc.selected.id
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
        },
        # Target group para el servicio de pagos
        {
          target_application_id = "api-payments"
          port                  = "8081"
          protocol              = "HTTP"
          vpc_id                = data.aws_vpc.selected.id
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/payments/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
        },
        # Target group para el servicio de autenticación
        {
          target_application_id = "api-auth"
          port                  = "8082"
          protocol              = "HTTP"
          vpc_id                = data.aws_vpc.selected.id
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/auth/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
        }
      ]
    },
    # Configuración del NLB interno para comunicación entre servicios
    {
      internal                   = true
      load_balancer_type         = "network"
      drop_invalid_header_fields = false
      idle_timeout               = 60
      enable_deletion_protection = true
      waf_arn                    = ""
      subnets                    = data.aws_subnets.public.ids
      security_groups            = []
      application_id             = "internal-services"
      
      listeners = [
        {
          protocol                = "TCP"
          port                    = "8080"
          certificate             = ""
          default_target_group_id = "internal-default"
          
          rules = []
        }
      ]
      
      target_groups = [
        {
          target_application_id = "internal-default"
          port                  = "8080"
          protocol              = "TCP"
          vpc_id                = data.aws_vpc.selected.id
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
        }
      ]
    }
  ]
  
  tags = {
    Owner       = "DevOps"
    Environment = "Development"
    Project     = "Payment Platform"
    Terraform   = "true"
  }
}

# Outputs para mostrar información de los recursos creados
output "alb_dns_name" {
  description = "DNS name of the payment API ALB"
  value       = module.load_balancer.load_balancer_info[0].alb_dns
}

output "nlb_dns_name" {
  description = "DNS name of the internal services NLB"
  value       = module.load_balancer.load_balancer_info[1].alb_dns
}

output "target_groups" {
  description = "All target groups created"
  value       = module.load_balancer.target_group_info
}
