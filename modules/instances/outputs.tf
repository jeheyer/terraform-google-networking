output "instances" {
  description = "Instances"
  value = { for i, v in local.instances :
    v.key => {
      name = try(google_compute_instance.default[v.key].name, null)
      zone = try(google_compute_instance.default[v.key].zone, null)
    } if v.create
  }
}

output "umigs" {
  description = "Unmanaged Instance Groups"
  value = { for i, v in local.umigs :
    v.key => {
      name = try(google_compute_instance_group.default[v.key].name, null)
      zone = try(google_compute_instance_group.default[v.key].zone, null)
    } if v.create
  }
}