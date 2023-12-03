
locals {
  autoscalers = [for i, v in local.migs :
    {
      project_id            = v.project_id
      name                  = v.name_prefix
      region                = v.region
      target                = try(google_compute_region_instance_group_manager.default[v.key].self_link, null)
      min_replicas          = v.min_replicas != 0 ? coalesce(v.min_replicas, 1) : null
      max_replicas          = v.max_replicas != 0 ? coalesce(v.max_replicas, 10) : null
      mode                  = v.autoscaling_mode
      cooldown_period       = coalesce(v.cooldown_period, 60)
      cpu_target            = coalesce(v.cpu_target, 0.60)
      cpu_predictive_method = coalesce(v.cpu_predictive_method, "NONE")
      is_regional           = v.is_regional
    } if v.autoscaling_mode != "OFF"
  ]
}
resource "google_compute_region_autoscaler" "default" {
  for_each = { for i, v in local.autoscalers : v.key => v if v.is_regional }
  name     = each.value.name
  project  = each.value.project_id
  region   = each.value.region
  target   = each.value.target
  autoscaling_policy {
    max_replicas    = each.value.max_replicas
    min_replicas    = each.value.min_replicas
    cooldown_period = each.value.cooldown_period
    mode            = each.value.mode
    cpu_utilization {
      target            = each.value.cpu_target
      predictive_method = each.value.cpu_predictive_method
    }
  }
}