############################################################################
# Modulo VPC 
############################################################################
module "vpc" {
  source = "../modules/cloudops-ref-repo-aws-vpc-terraform"  # Aquí apuntas al módulo local o un repositorio remoto

  client         = var.client
  functionality  = var.functionality
  environment    = var.environment
  
  cidr_block           = "10.60.0.0/22"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  subnet_config = {
    public-subnet = {
      public     = true
      include_nat = false
      subnets = [
        {
          cidr_block        = "10.60.0.0/26"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.60.0.64/26"
          availability_zone = "us-east-1b"
        }
      ]
       custom_routes = [
       ]
    }
    private-subnet = {
      public     = false
      include_nat = true
      subnets = [
        {
          cidr_block        = "10.60.0.128/26"
          availability_zone = "us-east-1a"
        },
        {
          cidr_block        = "10.60.0.192/26"
          availability_zone = "us-east-1b"
        }
      ]
       custom_routes = [
       ]
    }
  }

  create_igw = true
  create_nat = true
}
