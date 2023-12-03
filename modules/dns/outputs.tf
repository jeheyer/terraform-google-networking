
output "dns_zones" {
  value = [for i, v in local.dns_zones :
    {
      index_key    = v.index_key
      name         = try(google_dns_managed_zone.default[v.index_key].name, null)
      dns_name     = try(google_dns_managed_zone.default[v.index_key].dns_name, null)
      name_servers = try(google_dns_managed_zone.default[v.index_key].name_servers, null)
      visibility   = v.visibility
    }
  ]
}
output "dns_policies" {
  value = [for i, v in local.dns_policies :
    {
      index_key = v.index_key
      name      = try(google_dns_policy.default[v.index_key].name, null)
    }
  ]
}
