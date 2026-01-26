###########################################
# Data Sources for Sample
###########################################

# PC-IAC-026: Data sources para obtener IDs dinámicos

# Obtener la VPC por tags de nomenclatura estándar
data "aws_vpc" "selected" {
  provider = aws.principal
  
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

# Obtener subnets públicas
data "aws_subnets" "public" {
  provider = aws.principal
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# Obtener Security Group del ALB
data "aws_security_group" "alb" {
  provider = aws.principal
  
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-sg-alb"]
  }
}
