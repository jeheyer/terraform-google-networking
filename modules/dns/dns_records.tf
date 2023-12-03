locals {
  _dns_records = flatten([for dns_zone in local.dns_zones :
    [for record in dns_zone.records : {
      create         = coalesce(dns_zone.create, true)
      project_id     = dns_zone.project_id
      managed_zone   = dns_zone.name
      name           = record.name == "" ? dns_zone.dns_name : "${record.name}.${dns_zone.dns_name}"
      type           = upper(coalesce(record.type, "A"))
      ttl            = coalesce(record.ttl, 300)
      rrdatas        = coalesce(record.rrdatas, [])
      index_key      = record.index_key
      zone_index_key = dns_zone.index_key
    }]
  ])
  dns_records = [for i, v in local._dns_records :
    merge(v, {
      index_key = coalesce(v.index_key, "${v.zone_index_key}/${v.name}/${v.type}")
    }) if v.create == true
  ]
}

# DNS Records
resource "google_dns_record_set" "default" {
  for_each     = { for i, v in local.dns_records : v.index_key => v }
  project      = each.value.project_id
  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  depends_on   = [google_dns_managed_zone.default]
}
