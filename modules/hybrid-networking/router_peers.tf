locals {
  _router_peers = [for i, v in concat(local.interconnect_attachments, local.vpn_tunnels) :
    {
      create                    = v.create
      project_id                = v.project_id
      name                      = coalesce(v.peer_name, v.interface_name, "${v.name}-${i}")
      region                    = v.region
      router                    = v.router
      interface                 = v.interface_name
      peer_ip_address           = v.peer_ip_address
      advertised_groups         = v.advertised_groups
      peer_asn                  = coalesce(v.peer_asn, v.peer_is_gcp ? 64512 : 65000)
      advertise_mode            = length(coalesce(v.advertised_ip_ranges, [])) > 0 ? "CUSTOM" : "DEFAULT"
      advertised_route_priority = v.advertised_priority
      advertised_ip_ranges      = coalesce(v.advertised_ip_ranges, [])
      enable_bfd                = coalesce(v.enable_bfd, false)
      bfd_min_transmit_interval = coalesce(v.bfd_min_transmit_interval, 1000)
      bfd_min_receive_interval  = coalesce(v.bfd_min_receive_interval, 1000)
      bfd_multiplier            = coalesce(v.bfd_multiplier, 5)
      enable                    = coalesce(v.enable, true)
      enable_ipv6               = coalesce(v.enable_ipv6, false)
    }
  ]
  router_peers = [for i, v in local._router_peers :
    merge(v, {
      key = "${v.project_id}:${v.region}:${v.router}:${v.name}"
    }) if v.create
  ]
}

resource "google_compute_router_peer" "default" {
  for_each                  = { for i, v in local.router_peers : v.key => v }
  project                   = each.value.project_id
  name                      = each.value.name
  region                    = each.value.region
  router                    = each.value.router
  interface                 = each.value.interface
  peer_ip_address           = each.value.peer_ip_address
  peer_asn                  = each.value.peer_asn
  advertised_route_priority = each.value.advertised_route_priority
  advertised_groups         = each.value.advertised_groups
  advertise_mode            = each.value.advertise_mode
  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges
    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }
  dynamic "bfd" {
    for_each = [true] #each.value.enable_bfd ? [true] : []
    content {
      min_receive_interval        = each.value.bfd_min_receive_interval
      min_transmit_interval       = each.value.bfd_min_transmit_interval
      multiplier                  = each.value.bfd_multiplier
      session_initialization_mode = each.value.enable_bfd ? "ACTIVE" : "DISABLED"
    }
  }
  enable      = each.value.enable
  enable_ipv6 = each.value.enable_ipv6
  depends_on  = [google_compute_router_interface.default]
}
