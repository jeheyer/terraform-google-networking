output "vpc_networks" {
  description = "VPC Networks"
  value = [for vpc_network in local.vpc_networks :
    {
      index_key = vpc_network.index_key
      name      = try(google_compute_network.default[vpc_network.index_key].name, null)
      id        = try(google_compute_network.default[vpc_network.index_key].id, null)
      self_link = try(google_compute_network.default[vpc_network.index_key].self_link, null)
      subnets = [for subnet in local.subnets :
        {
          name     = subnet.name
          region   = subnet.region
          ip_range = subnet.ip_range
          id       = try(google_compute_subnetwork.default[subnet.index_key].id, null)
      } if subnet.network == vpc_network.name]
      peering_connections = [for peering_connection in local.peerings :
        {
          peer_network  = peering_connection.peer_network
          state         = try(google_compute_network_peering.default[peering_connection.index_key].state, null)
          state_details = try(google_compute_network_peering.default[peering_connection.index_key].state_details, null)
        }
      ]
      cloud_routers = [for cloud_router in local.cloud_routers :
        {
          name = cloud_router.name
          region = cloud_router.region
        }
      ]
      cloud_nats = [for cloud_nat in local.cloud_nats :
        {
          name = cloud_nat.name
          region = cloud_nat.region
          router = cloud_nat.router
        }
      ]
    }
  ]
}
