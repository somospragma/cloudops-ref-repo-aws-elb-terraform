locals {
  # Generar nombres estandarizados para los load balancers
  lb_names = {
    for key, lb in var.lb_config : key => join("-", [
      var.client,
      var.project,
      var.environment,
      "${lb.load_balancer_type == "application" ? "a" : "n"}lb",
      key
    ])
  }

  # Transformar los target groups para facilitar su referencia
  target_groups_map = {
    for key, lb in var.lb_config :
    key => {
      for tg in lb.target_groups : tg.target_application_id => {
        lb_key       = key
        target_group = tg
      }
    }
  }

  # Aplanar los target groups para facilitar su uso
  flattened_target_groups = merge([
    for lb_key, tg_map in local.target_groups_map : {
      for tg_key, tg in tg_map : tg_key => merge(tg, { lb_key = lb_key })
    }
  ]...)

  # Transformar los listeners para facilitar su referencia
  listeners_map = {
    for key, lb in var.lb_config :
    key => {
      for listener_idx, listener in lb.listeners : "${lb.application_id}-${listener.port}" => {
        lb_key         = key
        listener       = listener
        application_id = lb.application_id
      }
    }
  }

  # Aplanar los listeners para facilitar su uso
  flattened_listeners = merge([
    for lb_key, listener_map in local.listeners_map : {
      for listener_key, listener in listener_map : listener_key => merge(listener, { lb_key = lb_key })
    }
  ]...)

  # Transformar las reglas de listener para facilitar su referencia
  listener_rules = flatten([
    for lb_key, lb in var.lb_config : [
      for listener_idx, listener in lb.listeners : [
        for rule_idx, rule in listener.rules : {
          key               = "${rule.target_application_id}-${rule.priority}"
          lb_key            = lb_key
          listener_key      = "${lb.application_id}-${listener.port}"
          rule              = rule
          lb_application_id = lb.application_id
          listener_port     = listener.port
        }
      ]
    ]
  ])

  # Convertir las reglas a un mapa para usar con for_each
  listener_rules_map = {
    for rule in local.listener_rules : rule.key => rule
  }
}
