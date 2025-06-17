resource "aws_lb" "loadbalancer" {
  # checkov:skip=CKV_AWS_91: In first version of the module, resource won't include access logs
  provider                         = aws.project
  for_each                         = var.lb_config
  name                             = local.lb_names[each.key]
  internal                         = each.value.internal
  subnets                          = each.value.subnets
  security_groups                  = each.value.security_groups
  load_balancer_type               = each.value.load_balancer_type
  idle_timeout                     = each.value.idle_timeout
  drop_invalid_header_fields       = each.value.drop_invalid_header_fields ##Resource to solve CKV_AWS_131
  enable_deletion_protection       = each.value.enable_deletion_protection ##Resource to solve CKV_AWS_150
  enable_cross_zone_load_balancing = true                                  ##Resource to solve CKV_AWS_152

  tags = merge(
    { 
      Name = local.lb_names[each.key],
      application_id = each.value.application_id
    },
    each.value.additional_tags
  )
}

//Creacion asociacion waf con alb
resource "aws_wafv2_web_acl_association" "waf_lb" {
  provider     = aws.project
  for_each     = {for key, lb in var.lb_config : key => lb if lb.waf_arn != ""}
  resource_arn = aws_lb.loadbalancer[each.key].arn
  web_acl_arn  = each.value.waf_arn
}

resource "aws_lb_target_group" "lb_target_group" {
  provider    = aws.project
  for_each    = local.flattened_target_groups
  name        = join("-", [var.environment, "target", each.key])
  port        = each.value.target_group.port
  protocol    = each.value.target_group.protocol
  vpc_id      = each.value.target_group.vpc_id
  target_type = each.value.target_group.target_type

  health_check {
    healthy_threshold   = each.value.target_group.healthy_threshold
    interval            = each.value.target_group.interval
    port                = each.value.target_group.port
    protocol            = each.value.target_group.protocol
    unhealthy_threshold = each.value.target_group.unhealthy_threshold
    matcher             = each.value.target_group.matcher
    path                = each.value.target_group.path
  }

  tags = merge(
    { 
      Name = join("-", [var.environment, "target", each.key]),
      application_id = each.key
    },
    each.value.target_group.additional_tags
  )
}

resource "aws_lb_listener" "lb_listener" {
  # checkov:skip=CKV_AWS_2: protocol is send as variable
  provider    = aws.project
  for_each    = local.flattened_listeners
  
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group[each.value.listener.default_target_group_id].arn
    type             = "forward"
  }

  certificate_arn   = each.value.listener.certificate
  load_balancer_arn = aws_lb.loadbalancer[each.value.lb_key].arn
  port              = each.value.listener.port
  protocol          = each.value.listener.protocol
  
  tags = merge(
    { 
      Name = join("-", [var.environment, "listener", each.key]) 
    },
    lookup(each.value.listener, "additional_tags", {})
  )
}

resource "aws_lb_listener_rule" "listener_rule" {
  provider     = aws.project
  for_each     = local.listener_rules_map
  listener_arn = aws_lb_listener.lb_listener[each.value.listener_key].arn
  priority     = each.value.rule.priority

  action {
    type             = each.value.rule.action.type
    target_group_arn = aws_lb_target_group.lb_target_group[each.value.rule.target_application_id].arn
  }

  dynamic "condition" {
    for_each = each.value.rule.conditions
    content {
      dynamic "host_header" {
        for_each = condition.value.host_headers
        content {
          values = host_header.value.headers
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.path_patterns
        content {
          values = path_pattern.value.patterns
        }
      }
    }
  }
}
