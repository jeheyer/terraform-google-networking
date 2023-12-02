output "vpc_networks" {
  description = "VPC Networks"
  value = [for i, v in local.vpc_networks :
    {
      key       = v.key
      name      = try(google_compute_network.default[v.key].name, null)
      id        = try(google_compute_network.default[v.key].id, null)
      self_link = try(google_compute_network.default[v.key].self_link, null)
      subnets = [for i, s in local.subnets :
        {
          name     = s.name
          region   = s.region
          ip_range = s.ip_range
          id       = try(google_compute_subnetwork.default[s.key].id, null)
      } if s.network == v.name]
      peering_connections = [for i, p in local.peerings :
        {
          peer_network  = p.peer_network
          state_details = try(google_compute_network_peering.default[p.key].state_detils, null)
        }
      ]
    }
  ]
}

