output "instances" {
  description = "Instances"
  value = [for i, v in local.instances :
    {
      key  = v.key
      name = try(google_compute_instance.default[v.key].name, null)
      zone = try(google_compute_instance.default[v.key].zone, null)
    }
  ]
}

output "umigs" {
  description = "Unmanaged Instance Groups"
  value = [for i, v in local.umigs :
    {
      key  = v.key
      id   = try(google_compute_instance_group.default[v.key].id, null)
      self_link   = try(google_compute_instance_group.default[v.key].self_link, null)
      name = try(google_compute_instance_group.default[v.key].name, null)
      zone = try(google_compute_instance_group.default[v.key].zone, null)
    }
  ]
}
