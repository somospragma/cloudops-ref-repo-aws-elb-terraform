output "load_balancer_info" {
  description = "Información del balanceador de carga Hefesto"
  value       = module.hefesto_load_balancer.load_balancer_info
}

output "target_group_info" {
  description = "Información de los grupos de destino del balanceador de carga Hefesto"
  value       = module.hefesto_load_balancer.target_group_info
}
