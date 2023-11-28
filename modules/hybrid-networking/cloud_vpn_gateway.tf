locals {
  _cloud_vpn_gateways = [for i, v in var.cloud_vpn_gateways :
    merge(v, {
      create     = coalesce(v.create, true)
      project_id = coalesce(v.project_id, var.project_id)
      network    = coalesce(v.network_name, "default")
      region     = coalesce(v.region, var.region)
    })
  ]
  __cloud_vpn_gateways = [for i, v in local._cloud_vpn_gateways :
    merge(v, {
      name = coalesce(v.name, "vpngw-${v.network}")
    })
  ]
  cloud_vpn_gateways = [for i, v in local.__cloud_vpn_gateways :
    merge(v, {
      key = "${v.project_id}:${v.region}:${v.name}"
    }) if v.create
  ]
}

# Cloud HA VPN Gateway
resource "google_compute_ha_vpn_gateway" "default" {
  for_each = { for k, v in local.cloud_vpn_gateways : v.key => v }
  project  = each.value.project_id
  name     = each.value.name
  network  = each.value.network
  region   = each.value.region
}
