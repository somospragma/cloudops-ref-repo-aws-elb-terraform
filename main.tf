############################################################################
# AWS Application/Network Load Balancer - Módulo de Referencia
# Este módulo crea únicamente el Load Balancer (ALB/NLB)
# Los Target Groups y Listeners se gestionan en módulos separados
# Referencia: PC-IAC-023 (Responsabilidad Única)
############################################################################

# Load Balancer Resource
# Referencia: PC-IAC-010 (for_each), PC-IAC-020 (Hardenizado de Seguridad)
resource "aws_lb" "this" {
  provider = aws.project
  
  # PC-IAC-010: Uso de for_each con map para estabilidad
  for_each = var.lb_config
  
  # PC-IAC-003: Nomenclatura estándar desde locals
  name                             = local.lb_names[each.key]
  internal                         = each.value.internal
  subnets                          = each.value.subnets
  security_groups                  = each.value.security_groups
  load_balancer_type               = each.value.load_balancer_type
  idle_timeout                     = each.value.idle_timeout
  drop_invalid_header_fields       = each.value.drop_invalid_header_fields
  enable_deletion_protection       = each.value.enable_deletion_protection
  
  # PC-IAC-020: Cross-zone load balancing habilitado (Hardenizado de Seguridad)
  enable_cross_zone_load_balancing = true

  # PC-IAC-004: Etiquetas con merge de Name y additional_tags
  tags = merge(
    {
      Name           = local.lb_names[each.key]
      application_id = each.value.application_id
    },
    each.value.additional_tags
  )
}

# WAF Association (solo para Application Load Balancers)
# Referencia: PC-IAC-020 (Hardenizado de Seguridad - Protección de perímetro)
resource "aws_wafv2_web_acl_association" "this" {
  provider = aws.project
  
  # PC-IAC-010: for_each condicional solo para ALBs con WAF
  for_each = {
    for key, lb in var.lb_config : key => lb
    if lb.waf_arn != "" && lb.load_balancer_type == "application"
  }
  
  resource_arn = aws_lb.this[each.key].arn
  web_acl_arn  = each.value.waf_arn
}
