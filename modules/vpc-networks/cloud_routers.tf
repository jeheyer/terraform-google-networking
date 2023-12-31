locals {
  _cloud_routers = flatten([for vpc_network in local.vpc_networks :
    [for i, v in coalesce(vpc_network.cloud_routers, []) :
      {
        create                 = coalesce(v.create, true)
        project_id             = coalesce(v.project_id, vpc_network.project_id, var.project_id)
        name                   = coalesce(v.name, "rtr-${i}")
        description            = coalesce(v.description, "Managed by Terraform")
        region                 = coalesce(v.region, var.region)
        network                = vpc_network.name
        bgp_asn                = coalesce(v.bgp_asn, 64512)
        bgp_keepalive_interval = coalesce(v.bgp_keepalive_interval, 20)
        advertise_mode         = length(coalesce(v.advertised_ip_ranges, [])) > 0 ? "CUSTOM" : "DEFAULT"
        advertised_groups      = coalesce(v.advertised_groups, [])
        advertised_ip_ranges   = coalesce(v.advertised_ip_ranges, [])
      }
    ]
  ])
  cloud_routers = [for i, v in local._cloud_routers :
    merge(v, {
      index_key = "${v.project_id}/${v.region}/${v.name}"
    }) if v.create == true
  ]
}

# Cloud Routers
resource "google_compute_router" "default" {
  for_each    = { for k, v in local.cloud_routers : v.index_key => v }
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
  network     = each.value.network
  region      = each.value.region
  bgp {
    asn                = each.value.bgp_asn
    keepalive_interval = each.value.bgp_keepalive_interval
    advertise_mode     = each.value.advertise_mode
    advertised_groups  = each.value.advertised_groups
    dynamic "advertised_ip_ranges" {
      for_each = each.value.advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
  depends_on = [google_compute_network.default]
}
