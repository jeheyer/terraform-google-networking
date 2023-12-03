output "vpc_networks" {
  description = "VPC Networks"
  value = [for i, v in local.vpc_networks :
    {
      index_key = v.index_key
      name      = try(google_compute_network.default[v.index_key].name, null)
      id        = try(google_compute_network.default[v.index_key].id, null)
      self_link = try(google_compute_network.default[v.index_key].self_link, null)
      subnets = [for i, s in local.subnets :
        {
          name     = s.name
          region   = s.region
          ip_range = s.ip_range
          id       = try(google_compute_subnetwork.default[s.index_key].id, null)
      } if s.network == v.name]
      peering_connections = [for i, p in local.peerings :
        {
          peer_network  = p.peer_network
          state         = try(google_compute_network_peering.default[p.index_key].state, null)
          state_details = try(google_compute_network_peering.default[p.index_key].state_details, null)
        }
      ]
      cloud_routers = [for i, r in local.cloud_routers :
        {
          name = r.name
        }
      ]
    }
  ]
}
