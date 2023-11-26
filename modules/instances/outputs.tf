output "instances" {
  description = "Instances"
  value = { for i, v in local.instances :
    v.key => {
      name = try(google_compute_instance.default[v.key].name, null)
      zone = try(google_compute_instance.default[v.key].zone, null)
    } if v.create
  }
}
