output "name" { value = try(one(google_dns_managed_zone.default).name, null) }
output "description" { value = try(one(google_dns_managed_zone.default).description, null) }
output "dns_name" { value = try(one(google_dns_managed_zone.default).dns_name, null) }
output "name_servers" { value = try(one(google_dns_managed_zone.default).name_servers, null) }
output "visibility" { value = try(local.dns_zone.visibility, null) }
