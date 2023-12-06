locals {
  url_prefix = "https://www.googleapis.com/compute/v1/projects"
  _dns_zones = [for i, v in var.dns_zones :
    merge(v, {
      create              = coalesce(v.create, true)
      project_id          = coalesce(v.project_id, var.project_id)
      description         = coalesce(v.description, "Managed by Terraform")
      dns_name            = endswith(v.dns_name, ".") ? v.dns_name : "${v.dns_name}."
      peer_project_id     = coalesce(v.peer_project_id, var.project_id)
      visible_networks    = coalesce(v.visible_networks, [])
      target_name_servers = coalesce(v.target_name_servers, [])
      logging             = coalesce(v.logging, false)
      visibility          = lower(coalesce(v.visibility, "public"))
      records             = coalesce(v.records, [])
      force_destroy       = coalesce(v.force_destroy, false)
    })
  ]
  __dns_zones = [for i, v in local._dns_zones :
    merge(v, {
      name       = lower(coalesce(v.name, trimsuffix(replace(v.dns_name, ".", "-"), "-")))
      visibility = length(v.visible_networks) > 0 ? "private" : v.visibility
    })
  ]
  dns_zones = [for i, v in local.__dns_zones :
    merge(v, {
      is_private = v.visibility == "private" ? true : false
      is_public  = v.visibility == "public" ? true : false
      index_key  = "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}

# DNS Zones
resource "google_dns_managed_zone" "default" {
  for_each      = { for i, v in local.dns_zones : v.index_key => v if v.create }
  project       = each.value.project_id
  name          = each.value.name
  description   = each.value.description
  dns_name      = each.value.dns_name
  visibility    = each.value.visibility
  force_destroy = each.value.force_destroy
  dynamic "private_visibility_config" {
    for_each = each.value.is_private && length(each.value.visible_networks) > 0 ? [true] : []
    content {
      dynamic "networks" {
        for_each = each.value.visible_networks
        content {
          network_url = "${local.url_prefix}/${each.value.project_id}/global/networks/${networks.value}"
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = each.value.is_private && length(each.value.target_name_servers) > 0 ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = coalesce(target_name_servers.value.forwarding_path, "default")
        }
      }
    }
  }
  dynamic "peering_config" {
    for_each = each.value.peer_network_name != null ? [true] : []
    content {
      target_network {
        network_url = "projects/${each.value.peer_project_id}/global/networks/${each.value.peer_network_name}"
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable_logging = true
    }
  }
}
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
locals {
  _dns_policies = [for i, v in var.dns_policies :
    merge(v, {
      project_id                = coalesce(v.project_id, var.project_id)
      name                      = coalesce(v.name, "dns-policy-${i}")
      description               = coalesce(v.description, "Managed by Terraform")
      enable_inbound_forwarding = coalesce(v.enable_inbound_forwarding, true)
      target_name_servers       = coalesce(v.target_name_servers, [])
      networks                  = coalesce(v.networks, [])
      logging                   = coalesce(v.logging, false)
      create                    = coalesce(v.create, true)
    })
  ]
  dns_policies = [for i, v in local._dns_policies :
    merge(v, {
      index_key = coalesce(v.index_key, "${v.project_id}/${v.name}")
    })
  ]
}

# DNS Server Policies
resource "google_dns_policy" "default" {
  for_each                  = { for k, v in local.dns_policies : v.index_key => v if v.create }
  project                   = each.value.project_id
  name                      = each.value.name
  description               = each.value.description
  enable_logging            = each.value.logging
  enable_inbound_forwarding = each.value.enable_inbound_forwarding
  dynamic "alternative_name_server_config" {
    for_each = length(each.value.target_name_servers) > 0 ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = coalesce(target_name_servers.value.forwarding_path, "default")
        }
      }
    }
  }
  dynamic "networks" {
    for_each = each.value.networks
    content {
      network_url = "projects/${each.value.project_id}/global/networks/${networks.value}"
    }
  }
}
