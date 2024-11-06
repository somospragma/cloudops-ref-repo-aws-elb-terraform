# **Módulo Terraform: cloudops-ref-repo-aws-vpc-terraform**

## Descripción:

Este módulo facilita la creación de una Virtual Private Cloud (VPC) completa en AWS, proporcionando configuraciones de red, subredes, tablas de enrutamiento y gateways. Incluye la creación de subredes públicas y privadas, Internet Gateway (IGW), NAT Gateway, rutas personalizadas y VPC Flow Logs para una gestión eficiente y segura de la red.

Este módulo de Terraform para una VPC de AWS realizará las siguientes acciones:

- Crear una VPC con el CIDR block especificado.
- Crear subredes públicas y privadas según la configuración proporcionada.
- Configurar tablas de enrutamiento para cada subred.
- Crear un Internet Gateway (IGW) si se especifica.
- Crear un NAT Gateway si se especifica.
- Configurar rutas personalizadas según sea necesario.
- Configurar el grupo de seguridad predeterminado de la VPC.
- Implementar VPC Flow Logs para monitoreo y auditoría del tráfico de red (característica obligatoria).

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-vpc-terraform/
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
└── sample/
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars.sample
    └── variables.tf
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
provider "aws" {
  alias = "project"
  # ... otras configuraciones del provider
}

module "vpc" {
  source = "git::https://pragma.local/somospragma/cloudops-ref-repo-aws-vpc-terraform.git"
  providers = {
    aws.project = aws.project
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "vpc" {
  source = "git::https://pragma.local/somospragma/cloudops-ref-repo-aws-vpc-terraform.git"
  
  providers = {
    aws.project = aws.project
  }

  # VPC properties
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Subnet configuration
  subnet_config = {
    public = {
      public = true
      subnets = [
        {
          cidr_block        = "10.0.1.0/24"
          availability_zone = "us-west-2a"
        },
        {
          cidr_block        = "10.0.2.0/24"
          availability_zone = "us-west-2b"
        }
      ]
      custom_routes = []
    },
    private = {
      public = false
      include_nat = true
      subnets = [
        {
          cidr_block        = "10.0.3.0/24"
          availability_zone = "us-west-2a"
        },
        {
          cidr_block        = "10.0.4.0/24"
          availability_zone = "us-west-2b"
        }
      ]
      custom_routes = []
    }
  }

  # Gateway configuration
  create_igw = true
  create_nat = true

  # VPC Flow Logs configuration (obligatorio)
  flow_log_retention_in_days = 30

  # Common tags
  client        = "example"
  functionality = "network"
  environment   = "dev"
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
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_route_table.route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.internet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.custom_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_iam_role.vpc_flow_logs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.vpc_flow_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.vpc_flow_logs_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_cloudwatch_log_group.vpc_flow_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client"></a> [client](#input\_client) | Nombre del cliente | `string` | n/a | yes |
| <a name="input_functionality"></a> [functionality](#input\_functionality) | Funcionalidad del módulo | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Entorno de despliegue | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | El bloque CIDR para la VPC | `string` | n/a | yes |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Tenancy de las instancias lanzadas en la VPC | `string` | `"default"` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Habilitar soporte DNS para la VPC | `bool` | `true` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Habilitar nombres de host DNS para la VPC | `bool` | `true` | no |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | Configuración de subredes y rutas personalizadas. Es un mapa donde cada clave representa un grupo de subredes (por ejemplo, 'public', 'private') y el valor es un objeto con la siguiente estructura:<br>- `public`: (bool) Indica si la subred es pública.<br>- `include_nat`: (bool, opcional) Indica si la subred privada debe incluir un NAT Gateway. Por defecto es false.<br>- `subnets`: (list) Una lista de objetos, cada uno representando una subred con las siguientes propiedades:<br>  - `cidr_block`: (string) El bloque CIDR para la subred.<br>  - `availability_zone`: (string) La zona de disponibilidad para la subred.<br>- `custom_routes`: (list) Una lista de objetos, cada uno representando una ruta personalizada con las siguientes propiedades:<br>  - `destination_cidr_block`: (string) El bloque CIDR de destino para la ruta.<br>  - `carrier_gateway_id`: (string, opcional) ID del Carrier Gateway.<br>  - `core_network_arn`: (string, opcional) ARN de la red central.<br>  - `egress_only_gateway_id`: (string, opcional) ID del Egress Only Internet Gateway.<br>  - `nat_gateway_id`: (string, opcional) ID del NAT Gateway.<br>  - `local_gateway_id`: (string, opcional) ID del Local Gateway.<br>  - `network_interface_id`: (string, opcional) ID de la interfaz de red.<br>  - `transit_gateway_id`: (string, opcional) ID del Transit Gateway.<br>  - `vpc_endpoint_id`: (string, opcional) ID del VPC Endpoint.<br>  - `vpc_peering_connection_id`: (string, opcional) ID de la conexión de peering de VPC. | `map(object({`<br>`  public = bool`<br>`  include_nat = optional(bool, false)`<br>`  subnets = list(object({`<br>`    cidr_block = string`<br>`    availability_zone = string`<br>`  }))`<br>`  custom_routes = list(object({`<br>`    destination_cidr_block = string`<br>`    carrier_gateway_id = optional(string)`<br>`    core_network_arn = optional(string)`<br>`    egress_only_gateway_id = optional(string)`<br>`    nat_gateway_id = optional(string)`<br>`    local_gateway_id = optional(string)`<br>`    network_interface_id = optional(string)`<br>`    transit_gateway_id = optional(string)`<br>`    vpc_endpoint_id = optional(string)`<br>`    vpc_peering_connection_id = optional(string)`<br>`  }))`<br>`}))` | n/a | yes |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Crear Internet Gateway | `bool` | `false` | no |
| <a name="input_create_nat"></a> [create\_nat](#input\_create\_nat) | Crear NAT Gateway | `bool` | `false` | no |
| <a name="input_flow_log_retention_in_days"></a> [flow\_log\_retention\_in\_days](#input\_flow\_log\_retention\_in\_days) | Número de días para retener los logs de VPC Flow en CloudWatch | `number` | `30` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | El ID de la VPC creada |
