/*
output "cloud_routers" {
  value = { for i, v in local.cloud_routers : 
v.key => {
    name         = v.name
    region       = v.region
    network_name = v.network_name
    bgp_asn      = v.bgp_asn
  } #if v.create 
}
}
*/

output "cloud_vpn_gateways" {
  value = { for i, v in local.cloud_vpn_gateways :
    v.key => {
      name         = v.name
      region       = v.region
      ip_addresses = try(google_compute_ha_vpn_gateway.default[v.key].vpn_interfaces.*.ip_address, [])
    } #if v.create 
  }
}

output "peer_vpn_gateways" {
  value = { for i, v in local.peer_vpn_gateways :
    v.key => {
      name            = v.name
      redundancy_type = v.redundancy_type
      ip_addresses = [
        for interface in try(google_compute_external_vpn_gateway.default[v.key].interface, []) : interface.ip_address
      ]
  } } #if v.create }
}

output "vpn_tunnels" {
  value = { for k, v in local.vpn_tunnels :
    v.key => {
      name                    = v.name
      cloud_router_ip_address = v.ip_range
      peer_ip_address         = v.peer_ip_address
      peer_gateway_ip         = try(google_compute_vpn_tunnel.default[v.key].peer_ip, null)
      #cloud_vpn_gateway_ip    = try(google_compute_ha_vpn_gateway.default[v.cloud_vpn_gateway].vpn_interfaces[v.vpn_gateway_interface].ip_address, [])
      cloud_vpn_gateway_ip = try(google_compute_ha_vpn_gateway.default[v.cloud_vpn_gateway_key].vpn_interfaces.*.ip_address[v.tunnel_index, null)
      ike_version          = v.ike_version
      shared_secret        = v.shared_secret
      detailed_status      = try(google_compute_vpn_tunnel.default[v.key].detailed_status, "Unknown")
    }
  } # if v.create }
}

