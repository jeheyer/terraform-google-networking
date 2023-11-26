output "vpc_networks" {
  description = "VPC Networks"
  value = { for k, v in local.vpc_networks :
    v.key => {
      name = try(google_compute_network.default[v.key].name, null)
      id   = try(google_compute_network.default[v.key].id, null)
    } if v.create
  }
}
