locals {
  _ha_vpn_gateways = toset([for i, v in local.vpn_tunnels :
    "${v.project_id}:${v.region}:${v.cloud_vpn_gateway}"
  ])
  ha_vpn_gateways = { for v in local._ha_vpn_gateways :
    v => {
      project_id = element(split(":", v), 0)
      region     = element(split(":", v), 1)
      name       = element(split(":", v), 2)
    }
  }
}

# Query each relevant Cloud VPN Gateway to get its public IP addresses 
data "google_compute_ha_vpn_gateway" "default" {
  for_each = { for k, v in local.ha_vpn_gateways : k => v }
  project  = each.value.project_id
  region   = each.value.region
  name     = each.value.name
}
