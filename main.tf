####
# AWS Load Balance
###
resource "aws_lb" "loadbalancer" {
  provider = aws.project
  for_each = {
    for idx, lb in var.lb_config : "${lb.application_id}-${lb.load_balancer_type}" => lb
  }
  
  name               = join("-", tolist([var.client, var.environment, each.value.application_id, "${each.value.load_balancer_type == "application" ? "a" : "n"}lb"]))
  internal           = each.value.internal
  subnets           = each.value.subnets
  security_groups    = each.value.security_groups
  load_balancer_type = each.value.load_balancer_type
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  enable_cross_zone_load_balancing = true

  tags = merge({ 
    Name = join("-", tolist([var.client, var.environment, each.value.application_id, "${each.value.load_balancer_type == "application" ? "a" : "n"}lb"]))
  })
}


resource "aws_lb_target_group" "lb_target_group" {
  provider = aws.project
  for_each = {
    for item in flatten([for lb in var.lb_config : [for targets in lb.target_groups : {
      "target_application_id" : targets.target_application_id
      "port" : targets.port
      "protocol" : targets.protocol
      "vpc_id" : targets.vpc_id
      "target_type" : targets.target_type
      "healthy_threshold" : targets.healthy_threshold
      "interval" : targets.interval
      "path" : targets.path
      "unhealthy_threshold" : targets.unhealthy_threshold
    }]]) : "${item.target_application_id}" => item
  }
  
  name        = join("-", tolist([var.environment, "target", each.key]))
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = each.value.target_type

  health_check {
    healthy_threshold   = each.value.healthy_threshold
    interval           = each.value.interval
    path               = each.value.path
    port               = each.value.port
    protocol           = each.value.protocol
    unhealthy_threshold = each.value.unhealthy_threshold
  }

  tags = merge({ 
    Name = "${join("-", tolist([var.environment, "target", each.key]))}" 
  },
  { application_id = each.value.target_application_id})
}

resource "aws_lb_listener" "lb_listener" {
  provider = aws.project
  for_each = {
    for item in flatten([
      for lb in var.lb_config : [
        for listener in lb.listeners : {
          lb_key = "${lb.application_id}-${lb.load_balancer_type}"
          listener = listener
          key = "${lb.application_id}-${listener.port}"
        }
      ]
    ]) : item.key => item
  }

  # Aquí está el cambio: usamos lb_key en lugar de lb_index
  load_balancer_arn = aws_lb.loadbalancer[each.value.lb_key].arn
  port              = each.value.listener.port
  protocol          = each.value.listener.protocol
  certificate_arn   = each.value.listener.certificate_arn
  ssl_policy        = each.value.listener.protocol == "HTTPS" ? each.value.listener.ssl_policy : null

  dynamic "default_action" {
    for_each = each.value.listener.default_action.type == "forward" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.lb_target_group[each.value.listener.default_action.target_group_key].arn
    }
  }

  dynamic "default_action" {
    for_each = each.value.listener.default_action.type == "redirect" ? [1] : []
    content {
      type = "redirect"
      
      redirect {
        port        = each.value.listener.default_action.redirect.port
        protocol    = each.value.listener.default_action.redirect.protocol
        status_code = each.value.listener.default_action.redirect.status_code
      }
    }
  }
}