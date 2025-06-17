provider "aws" {
  region = "us-east-1"
}

module "load_balancer" {
  source      = "../../"
  client      = "banesco"
  service     = "api"
  environment = "dev"
  
  lb_config = [
    {
      internal                   = false
      load_balancer_type         = "application"
      drop_invalid_header_fields = true
      idle_timeout               = 60
      enable_deletion_protection = false
      waf_arn                    = ""
      subnets                    = ["subnet-12345678", "subnet-87654321"]
      security_groups            = ["sg-12345678"]
      application_id             = "payment-api"
      
      listeners = [
        {
          protocol                = "HTTPS"
          port                    = "443"
          certificate             = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef12-3456-7890-abcd-ef1234567890"
          default_target_group_id = "api-default"
          
          rules = [
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
            }
          ]
        }
      ]
      
      target_groups = [
        {
          target_application_id = "api-default"
          port                  = "8080"
          protocol              = "HTTP"
          vpc_id                = "vpc-12345678"
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/health"
          unhealthy_threshold   = "3"
          matcher               = "200"
        },
        {
          target_application_id = "api-payments"
          port                  = "8081"
          protocol              = "HTTP"
          vpc_id                = "vpc-12345678"
          target_type           = "ip"
          healthy_threshold     = "3"
          interval              = "30"
          path                  = "/payments/health"
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
  }
}
