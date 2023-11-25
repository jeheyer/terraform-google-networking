
output "dns_zones" {
  value = { for i, v in local.dns_zones :
    v.key => {
      name         = try(google_dns_managed_zone.default[v.key].name, null)
      dns_name     = try(google_dns_managed_zone.default[v.key].dns_name, null)
      name_servers = try(google_dns_managed_zone.default[v.key].name_servers, null)
      visibility   = v.visibility
    } if v.create
  }
}
output "dns_policies" {
  value = { for k, v in local.dns_policies :
    v.key => {
      name = try(google_dns_policy.default[v.key].name, null)
    } if v.create
  }
}
output "service_attachments" {
  description = "PSC Published Service Attachments"
  value = { for k, v in local.service_attachments :
    v.key => {
      name      = try(google_compute_service_attachment.default[v.key].name, null)
      self_link = try(google_compute_service_attachment.default[v.key].self_link, null)
    } if v.create
  }
}
