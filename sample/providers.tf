###########################################
# Provider Configuration for Sample
###########################################

# PC-IAC-005: Configuración del provider principal

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
  }
}

provider "aws" {
  alias  = "principal"
  region = "us-east-1"
  
  # PC-IAC-004: Default tags para gobernanza
  default_tags {
    tags = {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "cloudops-ref-repo-aws-elb-terraform"
    }
  }
}
