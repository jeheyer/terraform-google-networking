output "vpn_tunnels" {
  value = [for k, v in module.vpns.vpn_tunnels :
    {
      name                    = v.name
      ike_version             = v.ike_version
      shared_secret           = v.shared_secret
      cloud_vpn_gateway_ip    = v.cloud_vpn_gateway_ip
      peer_vpn_gateway_ip     = v.peer_gateway_ip
      detailed_status         = v.detailed_status
      cloud_router_ip_address = v.cloud_router_ip_address
      peer_ip_address         = v.peer_ip_address
      #peer_bgp_asn            = v.peer_bgp_asn
      cloud_router_bgp_asn    = try(data.google_compute_router.cloud_router.bgp[0].asn, "ERROR")
    }
  ]
}
