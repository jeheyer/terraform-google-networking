locals {
  dns_zones = [for v in [var.dns_zone] :
    merge(v, {
      project_id          = coalesce(v.project_id, var.project_id)
      description         = coalesce(v.description, "Managed by Terraform")
      dns_name            = endswith(v.dns_name, ".") ? v.dns_name : "${v.dns_name}."
      peer_project_id     = coalesce(v.peer_project_id, v.project_id, var.project_id)
      visible_networks    = coalesce(v.visible_networks, [])
      target_name_servers = coalesce(v.target_name_servers, [])
      logging             = coalesce(v.logging, false)
      visibility          = lower(coalesce(v.visibility, "public"))
      records             = coalesce(v.records, [])
      force_destroy       = coalesce(v.force_destroy, false)
    }) if var.dns_zone != null
  ]
  dns_zone = one([for v in local.dns_zones :
    merge(v, {
      name       = lower(coalesce(v.name, trimsuffix(replace(v.dns_name, ".", "-"), "-")))
      visibility = length(v.visible_networks) > 0 ? "private" : v.visibility
    })
  ])
}

# DNS Zones
resource "google_dns_managed_zone" "default" {
  #  for_each      = { for i, v in local.dns_zone : 0 => v }
  count         = local.dns_zone.create ? 1 : 0
  project       = local.dns_zone.project_id
  name          = local.dns_zone.name
  description   = local.dns_zone.description
  dns_name      = local.dns_zone.dns_name
  visibility    = local.dns_zone.visibility
  force_destroy = local.dns_zone.force_destroy
  dynamic "private_visibility_config" {
    for_each = local.dns_zone.visibility == "private" ? [true] : []
    content {
      dynamic "networks" {
        for_each = local.dns_zone.visible_networks
        content {
          network_url = "${local.url_prefix}/${local.dns_zone.project_id}/global/networks/${networks.value}"
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = local.dns_zone.visibility == "private" ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = local.dns_zone.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = coalesce(target_name_servers.value.forwarding_path, "default")
        }
      }
    }
  }
  dynamic "peering_config" {
    for_each = local.dns_zone.peer_network_name != null ? [true] : []
    content {
      target_network {
        network_url = "projects/${local.dns_zone.peer_project_id}/global/networks/${local.dns_zone.peer_network_name}"
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = local.dns_zone.logging ? [true] : []
    content {
      enable_logging = true
    }
  }
}

locals {
  dns_records_0 = flatten([for i, v in local.dns_zones :
    [for r in v.records :
      {
        project_id   = v.project_id
        managed_zone = v.name
        name         = r.name == "" ? v.dns_name : "${r.name}.${v.dns_name}"
        type         = upper(coalesce(r.type, "A"))
        ttl          = coalesce(r.ttl, 300)
        rrdatas      = coalesce(r.rrdatas, [])
        zone_key     = v.key
      }
    ] if lookup(v, "create", true)
  ])
  dns_records = [for i, v in local.dns_records_0 :
    merge(v, {
      key = "${v.zone_key}:${v.name}:${v.type}"
    })
  ]
}

# DNS Records
resource "google_dns_record_set" "default" {
  for_each     = { for i, v in local.dns_records : v.key => v }
  project      = each.value.project_id
  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  depends_on   = [google_dns_managed_zone.default]
}
