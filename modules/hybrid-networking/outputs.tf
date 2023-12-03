
output "cloud_vpn_gateways" {
  value = [for i, v in local.cloud_vpn_gateways :
    {
      index_key    = v.index_key
      name         = v.name
      region       = v.region
      ip_addresses = try(google_compute_ha_vpn_gateway.default[v.index_key].vpn_interfaces.*.ip_address, [])
    }
  ]
}

output "peer_vpn_gateways" {
  value = [for i, v in local.peer_vpn_gateways :
    {
      index_key       = v.index_key
      name            = v.name
      redundancy_type = v.redundancy_type
      ip_addresses = [
        for interface in try(google_compute_external_vpn_gateway.default[v.index_key].interface, []) : interface.ip_address
      ]
    }
  ]
}

output "vpn_tunnels" {
  value = [for k, v in local.vpn_tunnels :
    {
      index_key               = v.key
      name                    = v.name
      cloud_router_ip_address = v.ip_range
      peer_ip_address         = v.peer_ip_address
      peer_gateway_ip         = try(google_compute_vpn_tunnel.default[v.index_key].peer_ip, null)
      cloud_vpn_gateway_ip    = try(data.google_compute_ha_vpn_gateway.default[v.cloud_vpn_gateway_key].vpn_interfaces.*.ip_address[v.tunnel_index], "unknown")
      ike_version             = v.ike_version
      shared_secret           = v.shared_secret
      detailed_status         = try(google_compute_vpn_tunnel.default[v.index_key].detailed_status, "Unknown")
    }
  ]
}

