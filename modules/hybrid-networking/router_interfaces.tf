locals {
  _router_interfaces = [for i, v in concat(local.interconnect_attachments, local.vpn_tunnels) :
    {
      create                  = v.create
      project_id              = v.project_id
      region                  = v.region
      router                  = v.router
      ip_range                = v.ip_range
      name                    = lower(trimspace(v.interface_name))
      vpn_tunnel              = v.is_vpn ? v.vpn_tunnel : null
      interconnect_attachment = v.is_interconnect ? v.attachment_name : null
    }
  ]
  router_interfaces = [for i, v in local._router_interfaces :
    merge(v, {
      index_key = "${v.project_id}/${v.region}/${v.router}/${v.name}"
    }) if v.create
  ]
}

# Cloud Router Interface
resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : v.index_key => v }
  project                 = each.value.project_id
  name                    = each.value.name
  region                  = each.value.region
  router                  = each.value.router
  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.vpn_tunnel
  interconnect_attachment = each.value.interconnect_attachment
  depends_on              = [google_compute_interconnect_attachment.default, google_compute_vpn_tunnel.default]
}

