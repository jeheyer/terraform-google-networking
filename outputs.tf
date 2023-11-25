
output "vpc-networks" {
  description = "VPC Networks"
  value = {
    for i, v in local.vpc_networks : v.key => {
      name = try(module.vpc-networks[v.key].name, null)
    } if v.create
  }
}

output "dns_zones" {
  description = "DNS Zones"
  value = {
    for i, v in local.dns_zones : v.key => {
      name         = try(module.dns-zone[v.key].name, null)
      description  = try(module.dns-zone[v.key].description, null)
      dns_name     = try(module.dns-zone[v.key].dns_name, null)
      name_servers = try(module.dns-zone[v.key].name_servers, null)
      visibility   = module.dns-zone[v.key].visibility
    } if v.create
  }
}
output "dns_policies" {
  description = "DNS Policies"
  value = {
    for k, v in local.dns_policies : v.key => {
      name = try(google_dns_policy.default[v.key].name, null)
    }
  }
}
output "service_attachments" {
  description = "PSC Published Service Attachments"
  value = {
    for k, v in local.service_attachments : v.key => {
      name      = try(google_compute_service_attachment.default[v.key].name, null)
      self_link = try(google_compute_service_attachment.default[v.key].self_link, null)
    }
  }
}
