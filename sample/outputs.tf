###########################################
# Sample Outputs
###########################################

output "load_balancer_info" {
  description = "Complete information about the created load balancers"
  value       = module.load_balancers.load_balancer_info
}

output "load_balancer_arns" {
  description = "ARNs of the created load balancers"
  value       = module.load_balancers.load_balancer_arns
}

output "load_balancer_dns_names" {
  description = "DNS names of the created load balancers"
  value       = module.load_balancers.load_balancer_dns_names
}
