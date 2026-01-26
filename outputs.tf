###########################################
# Module Outputs
###########################################

# PC-IAC-007: Outputs granulares con Splat Expressions
# PC-IAC-014: Uso de Splat Expressions para extracción de colecciones

output "load_balancer_info" {
  description = "Complete information about the created load balancers, organized by key"
  value = {
    for key, lb in aws_lb.this : key => {
      arn            = lb.arn
      dns_name       = lb.dns_name
      zone_id        = lb.zone_id
      application_id = lb.tags_all.application_id
      name           = lb.name
      arn_suffix     = lb.arn_suffix
    }
  }
}

output "load_balancer_arns" {
  description = "Map of load balancer ARNs by key"
  value       = { for key, lb in aws_lb.this : key => lb.arn }
}

output "load_balancer_dns_names" {
  description = "Map of load balancer DNS names by key"
  value       = { for key, lb in aws_lb.this : key => lb.dns_name }
}

output "load_balancer_zone_ids" {
  description = "Map of load balancer zone IDs by key"
  value       = { for key, lb in aws_lb.this : key => lb.zone_id }
}
