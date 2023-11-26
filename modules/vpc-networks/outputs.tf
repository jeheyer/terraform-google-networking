output "vpc_networks" {
  description = "VPC Networks"
  value = { for n in local.vpc_networks :
    n.key => {
      name      = try(google_compute_network.default[n.key].name, null)
      id        = try(google_compute_network.default[n.key].id, null)
      self_link = try(google_compute_network.default[n.key].self_link, null)
      subnets = [for i, s in local.subnets :
        {
          name     = s.name
          region   = s.region
          ip_range = s.ip_range
          id       = try(google_compute_subnetwork.default[s.key].id, null)
      } if s.network == n.name]
    } if n.create
  }
}
