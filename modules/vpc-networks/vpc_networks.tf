locals {
  vpc_networks_0 = [for i, v in coalesce(var.vpc_networks, []) :
    merge(v, {
      project_id              = coalesce(v.project_id, var.project_id)
      name                    = coalesce(v.name, "vpc-network-${i}")
      mtu                     = coalesce(v.mtu, 1460)
      routing_mode            = v.enable_global_routing == true ? "GLOBAL" : "REGIONAL"
      auto_create_subnetworks = coalesce(v.auto_create_subnetworks, false)
    }) if v.create
  ]
  vpc_networks = [for i, v in local.vpc_networks_0 :
    merge(v, {
      key = "${v.project_id}:${v.name}"
    })
  ]
}

# VPC Network
resource "google_compute_network" "default" {
  for_each                = { for i, v in local.vpc_networks : v.key => v }
  project                 = each.value.project_id
  name                    = each.value.name
  description             = each.value.description
  mtu                     = each.value.mtu
  routing_mode            = each.value.routing_mode
  auto_create_subnetworks = each.value.auto_create_subnetworks
}
