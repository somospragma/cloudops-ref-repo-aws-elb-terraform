# outputs.tf
output "load_balancer_info" {
  value = [for lb in aws_lb.loadbalancer : {
    "alb_arn" : lb.arn, 
    "alb_dns" : lb.dns_name, 
    "alb_zone": lb.zone_id
  }]
}

output "target_group_info" {
  value = {
    for target in aws_lb_target_group.lb_target_group : 
    target.tags_all.application_id => {
      "target_arn" : target.arn, 
      "target_name" : target.name
    }
  }
}