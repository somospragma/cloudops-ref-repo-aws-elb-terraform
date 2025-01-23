# **Módulo Terraform: cloudops-ref-repo-aws-elb-terraform**

## Descripción:

Este módulo facilita la creación de un Elastic Load Balancer (ELB) completo en AWS, realizando las siguientes acciones:

- Crear Load Balancer
- Crear Target Group
- Crear Listener

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-elb-terraform/
└── sample/elb
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars.sample
    └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/elb/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/elb/main.tf
module "elb" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "elb" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client        = "example"
  project       = "example"
  environment   = "dev"
  aws_region    = "us-east-1"
  common_tags = {
      environment   = "dev"
      project-name  = "proyecto01"
      cost-center   = "xxx"
      owner         = "xxx"
      area          = "xxx"
      provisioned   = "xxx"
      datatype      = "xxx"
  }

  # LB configuration
  lb_config = [{
    internal           = false
    load_balancer_type = "application"
    subnets            = [data.aws_subnet.public_subnet_1.id, data.aws_subnet.public_subnet_2.id]
    security_groups    = [module.sg_alb.sg_info["alb-app01"].sg_id]
    application_id     = app01

    # Target Group configuration
    target_groups = [{
        target_application_id = web01 #(PENDING FOR VALIDATION)
        port                  = 8080
        protocol              = "HTTP"
        vpc_id                = data.aws_vpc.vpc.id
        target_type           = "ip"
        healthy_threshold     = "2"
        interval              = "30"
        path                  = "/health"
        unhealthy_threshold   = "2"
    }]

    # Listeners configuration
    listeners = [
        # HTTP Listener (80) to redirect to HTTPS
        {
            port     = 8080
            protocol = "HTTP"
            default_action = {
                type = "redirect"
                redirect = {
                port        = "443"
                protocol    = "HTTPS"
                status_code = "HTTP_301"
                }
            }
        },
        # HTTPS Listener (443) to send to the above target group ⬆
        {
            port            = 443
            protocol        = "HTTPS"
            certificate_arn = "PENDING"
            default_action = {
                type             = "forward"
                target_group_key = "web01"
            }
        }
    ]
}]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.loadbalancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_listener.lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="internal"></a> [internal](#input\internal) | If true, the LB will be internal | `bool` | n/a | yes |
| <a name="load_balancer_type"></a> [load_balancer_type](#input\load_balancer_type) | Type of load balancer | `string` | n/a | yes |
| <a name="subnets"></a> [subnets](#input\subnets) | List of subnet IDs to attach to the LB | `list(string)` | n/a | yes |
| <a name="security_groups"></a> [security_groups](#input\security_groups) | List of security group IDs to assign to the LB | `list(string)` | n/a | yes |
| <a name="application"></a> [application](#input\application) | Aplication name | `string` | n/a | yes |
| <a name="target_groups.target_application_id"></a> [target_groups.target_application_id](#input\target_groups.target_application_id) | PENDING | `string` | n/a | yes |
| <a name="target_groups.port"></a> [target_groups.port](#input\target_groups.port) | Port on which targets receive traffic | `string` | n/a | yes |
| <a name="target_groups.protocol"></a> [target_groups.protocol](#input\target_groups.protocol) | Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| <a name="target_groups.vpc_id"></a> [target_groups.vpc_id](#input\target_groups.vpc_id) | Identifier of the VPC in which to create the target group | `string` | n/a | yes |
| <a name="target_groups.target_type"></a> [target_groups.target_type](#input\target_groups.target_type) | Type of target | `string` | n/a | yes |
| <a name="target_groups.healthy_threshold"></a> [target_groups.healthy_threshold](#input\target_groups.healthy_threshold) | Number of consecutive health check successes | `string` | n/a | yes |
| <a name="target_groups.interval"></a> [target_groups.interval](#input\target_groups.interval) | Approximate amount of time, in seconds, between health checks of an individual target | `string` | n/a | yes |
| <a name="target_groups.path"></a> [target_groups.path](#input\target_groups.path) | Destination for the health check request | `string` | n/a | yes |
| <a name="target_groups.unhealthy_threshold"></a> [target_groups.unhealthy_threshold](#input\target_groups.unhealthy_threshold) | Number of consecutive health check failures | `string` | n/a | yes |
| <a name="listeners.port"></a> [listeners.port](#input\listeners.port) | Port on which the load balancer is listening | `number` | n/a | yes |
| <a name="listeners.protocol"></a> [listeners.protocol](#input\listeners.protocol) | Protocol for connections from clients to the load balancer | `string` | n/a | yes |
| <a name="listeners.certificate_arn"></a> [listeners.certificate_arn](#input\listeners.certificate_arn) | ARN of the default SSL server certificate | `string` | n/a | no |
| <a name="listeners.ssl_policy"></a> [listeners.ssl_policy](#input\listeners.ssl_policy) | Name of the SSL Policy for the listener | `string` | n/a | yes |
| <a name="listeners.default_action.type"></a> [listeners.default_action.type](#input\listeners.default_action.type) | Type of routing action | `string` | n/a | yes |
| <a name="listeners.default_action.target_group_key"></a> [listeners.default_action.target_group_key](#input\listeners.default_action.target_group_key) | ARN of the Target Group to which to route traffic | `string` | n/a | no |
| <a name="listeners.default_action.redirect.port"></a> [listeners.default_action.redirect.port](#input\listeners.default_action.redirect.port) | Port | `string` | n/a | no |
| <a name="listeners.default_action.redirect.protocol"></a> [listeners.default_action.redirect.protocol](#input\listeners.default_action.redirect.protocol) | Protocol | `string` | n/a | no |
| <a name="listeners.default_action.redirect.status_code"></a> [listeners.default_action.redirect.status_code](#input\listeners.default_action.redirect.status_code) | Status code | `string` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="load_balancer_info.arn"></a> [load_balancer_info.arn](#output\load_balancer_info.arn) | ARN del balanceador |
| <a name="load_balancer_info.dns_name"></a> [load_balancer_info.dns_name](#output\load_balancer_info.dns_name) | DNS del balanceador |
| <a name="load_balancer_info.zone_id"></a> [load_balancer_info.zone_id](#output\load_balancer_info.zone_id) | Id de la zona del balanceador |
| <a name="target_group_info.arn"></a> [target_group_info.arn](#output\target_group_info.arn) | ARN del target group |
| <a name="target_group_info.name"></a> [target_group_info.name](#output\target_group_info.name) | Nombre del target group |
