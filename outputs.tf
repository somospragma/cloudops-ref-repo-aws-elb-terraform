output "load_balancer_info" {
  description = "Información de los balanceadores de carga creados, organizados por clave"
  value = {
    for key, lb in aws_lb.loadbalancer : key => {
      "alb_arn" : lb.arn, 
      "alb_dns" : lb.dns_name, 
      "alb_zone": lb.zone_id,
      "application_id": lb.tags_all.application_id
    }
  }
}

output "target_group_info" {
  description = "Información de los grupos de destino creados, organizados por application_id"
  value = {
    for key, target in aws_lb_target_group.lb_target_group : key => {
      "target_arn" : target.arn, 
      "target_name" : target.name
    }
  }
}
