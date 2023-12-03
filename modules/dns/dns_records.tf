locals {
  dns_records_0 = flatten([
    for z in local.dns_zones : [
      for r in z.records : {
        create         = coalesce(z.create, true)
        project_id     = z.project_id
        managed_zone   = z.name
        name           = z.name == "" ? z.dns_name : "${r.name}.${z.dns_name}"
        type           = upper(coalesce(r.type, "A"))
        ttl            = coalesce(r.ttl, 300)
        rrdatas        = coalesce(r.rrdatas, [])
        index_key      = r.index_key
        zone_index_key = z.index_key
      }
    ]
  ])
  dns_records = [for i, v in local.dns_records_0 :
    merge(v, {
      index_key = coalesce(v.index_key, "${v.zone_index_key}/${v.name}/${v.type}")
    }) if v.create
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
