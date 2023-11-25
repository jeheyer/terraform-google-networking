
# VPC Networks
locals {
  vpc_networks = [for i, v in var.vpc_networks :
    merge(v, {
      key = "${coalesce(v.project_id, var.project_id)}::${v.name}"
    })
  ]
}
module "vpc-networks" {
  source                  = "git::https://github.com/jeheyer/terraform-google-networking//modules/vpc-network"
  for_each                = { for i, v in local.vpc_networks : v.key => v if v.create }
  project_id              = var.project_id
  network_name            = each.value.name
  mtu                     = each.value.mtu
  enable_global_routing   = each.value.enable_global_routing
  auto_create_subnetworks = each.value.auto_create_subnetworks
  attached_projects       = each.value.attached_projects
  shared_accounts         = each.value.shared_accounts
  subnets                 = each.value.subnets
  peerings                = each.value.peerings
  routes                  = each.value.routes
  ip_ranges               = each.value.ip_ranges
  service_connections     = each.value.service_connections
  cloud_routers           = each.value.cloud_routers
  cloud_nats              = each.value.cloud_nats
  defaults                = var.defaults
}

# DNS Zones
locals {
  dns_zones_0 = [for i, v in var.dns_zones :
    merge(v, {
      project_id = coalesce(v.project_id, var.project_id)
      name       = lower(coalesce(v.name, trimsuffix(replace(v.dns_name, ".", "-"), "-")))
    })
  ]
  dns_zones = [for i, v in local.dns_zones_0 :
    merge(v, {
      key = "${v.project_id}::${v.name}"
    })
  ]
}
module "dns-zone" {
#  source     = "./modules/dns-zone"
  source                  = "git::https://github.com/jeheyer/terraform-google-networking//modules/dns-zone"
  for_each   = { for i, v in local.dns_zones : v.key => v if v.create }
  project_id = var.project_id
  dns_zone   = each.value
}
