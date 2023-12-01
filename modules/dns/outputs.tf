
output "dns_zones" {
  value = [for i, v in local.dns_zones :
    {
      key          = v.key
      name         = try(google_dns_managed_zone.default[v.key].name, null)
      dns_name     = try(google_dns_managed_zone.default[v.key].dns_name, null)
      name_servers = try(google_dns_managed_zone.default[v.key].name_servers, null)
      visibility   = v.visibility
    }
  ]
}
output "dns_policies" {
  value = [for i, v in local.dns_policies :
    {
      key  = v.key
      name = try(google_dns_policy.default[v.key].name, null)
    }
  ]
}
