locals {
  _vpn_tunnels = flatten(
    [for i, vpn in var.vpns :
      [for t, tunnel in vpn.tunnels :
        {
          create                          = coalesce(tunnel.create, true)
          is_vpn                          = true
          is_interconnect                 = false
          project_id                      = coalesce(vpn.project_id, var.project_id)
          region                          = coalesce(vpn.region, var.region)
          router                          = coalesce(vpn.cloud_router, "error")
          cloud_vpn_gateway               = vpn.cloud_vpn_gateway
          peer_gcp_vpn_gateway_project_id = coalesce(vpn.peer_gcp_vpn_gateway_project_id, vpn.project_id, var.project_id)
          peer_gcp_vpn_gateway            = vpn.peer_gcp_vpn_gateway
          peer_external_gateway           = try(coalesce(vpn.peer_vpn_gateway, try(local.peer_vpn_gateways[vpn.peer_vpn_gateway].name, null)), null)
          description                     = try(coalesce(tunnel.description, vpn.description), null)
          ip_range                        = tunnel.cloud_router_ip
          ike_version                     = coalesce(tunnel.ike_version, var.defaults.vpn_ike_version, 2)
          ike_psk                         = tunnel.ike_psk
          vpn_gateway_interface           = coalesce(tunnel.interface_index, t % 2 == 0 ? 0 : 1)
          peer_external_gateway_interface = coalesce(tunnel.peer_interface_index, t)
          advertised_ip_ranges            = coalesce(tunnel.advertised_ip_ranges, vpn.advertised_ip_ranges, [])
          advertised_groups               = coalesce(tunnel.advertised_groups, vpn.advertised_groups, [])
          advertised_priority             = coalesce(tunnel.advertised_priority, vpn.advertised_priority, 100)
          peer_bgp_name                   = tunnel.peer_bgp_name
          peer_ip_address                 = tunnel.peer_bgp_ip
          peer_asn                        = try(coalesce(tunnel.peer_bgp_asn, vpn.peer_bgp_asn), null)
          enable                          = coalesce(tunnel.enable, true)
          enable_ipv6                     = coalesce(tunnel.enable, false)
          enable_bfd                      = try(coalesce(tunnel.enable_bfd, vpn.enable_bfd), null)
          bfd_min_transmit_interval       = 1000
          bfd_min_receive_interval        = 1000
          bfd_multiplier                  = vpn.bfd_multiplier
          vpn_name                        = vpn.name
          tunnel_name                     = tunnel.name
          interface_name                  = tunnel.interface_name
          vpn_index                       = i
          tunnel_index                    = t
        }
      ]
    ]
  )
  __vpn_tunnels = [for i, v in local._vpn_tunnels :
    merge(v, {
      name        = coalesce(v.tunnel_name, v.vpn_name != null ? "${v.vpn_name}-${v.tunnel_index}" : null, "vpn-${v.region}-${v.vpn_index}-${v.tunnel_index}")
      peer_is_gcp = v.peer_gcp_vpn_gateway != null ? true : false
    })
  ]
  ___vpn_tunnels = [for i, v in local.__vpn_tunnels :
    merge(v, {
      interface_name        = coalesce(v.interface_name, "${v.name}")
      peer_bgp_name         = coalesce(v.peer_bgp_name, "${v.name}-${v.tunnel_index}")
      index_key             = "${v.project_id}/${v.region}/${v.name}"
      cloud_vpn_gateway_key = "${v.project_id}/${v.region}/${v.cloud_vpn_gateway}"
    })
  ]
}

# Generate a random PSK for each tunnel, if required
resource "random_string" "ike_psks" {
  for_each = { for i, v in local.___vpn_tunnels : v.index_key => true if v.ike_psk == null }
  length   = lookup(var.defaults, "vpn_ike_psk_length", 20)
  special  = false
}

locals {
  gcp_gateway_prefix = "https://www.googleapis.com/compute/v1/projects"
  vpn_tunnels = [for i, v in local.___vpn_tunnels :
    merge(v, {
      vpn_tunnel       = v.name
      vpn_gateway      = coalesce(v.cloud_vpn_gateway, try(local.cloud_vpn_gateways[v.cloud_vpn_gateway].name, "error"))
      peer_gcp_gateway = v.peer_is_gcp ? "${local.gcp_gateway_prefix}/${v.peer_gcp_vpn_gateway_project_id}/regions/${v.region}/vpnGateways/${v.peer_gcp_vpn_gateway}" : null
      shared_secret = coalesce(
        v.ike_psk,
        var.defaults.vpn_ike_psk,
        try(resource.random_string.ike_psks[v.index_key].result, null),
        "abcdefghij0123456789"
      )
      peer_external_gateway_interface = v.peer_is_gcp ? null : v.peer_external_gateway_interface
    }) if v.create
  ]
}

# Generate a null resource for each VPN tunnel, so that an existing tunnel is completely destroyed before attempting create
# https://github.com/hashicorp/terraform-provider-google/issues/16619
resource "null_resource" "vpn_tunnels" {
  for_each = { for i, v in local.vpn_tunnels : v.index_key => true }
}

resource "google_compute_vpn_tunnel" "default" {
  for_each                        = { for i, v in local.vpn_tunnels : v.index_key => v }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  region                          = each.value.region
  router                          = each.value.router
  peer_ip                         = null # Classic VPN only?
  vpn_gateway                     = each.value.vpn_gateway
  peer_external_gateway           = each.value.peer_external_gateway
  peer_gcp_gateway                = each.value.peer_gcp_gateway
  ike_version                     = each.value.ike_version
  shared_secret                   = each.value.shared_secret
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  depends_on = [
    google_compute_ha_vpn_gateway.default,
    google_compute_external_vpn_gateway.default,
    null_resource.vpn_tunnels,
  ]
}
