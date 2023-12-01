locals {
  _firewall_rules = [
    for i, v in var.firewall_rules :
    merge(v, {
      create         = coalesce(v.create, true)
      project_id     = lower(trimspace(coalesce(v.project_id, var.project_id)))
      disabled       = coalesce(v.disabled, false)
      gen_short_name = v.name == null && v.short_name == null ? true : false
      priority       = coalesce(v.priority, 1000)
      logging        = coalesce(v.logging, false)
      direction      = length(coalesce(v.destination_ranges, [])) > 0 ? "EGRESS" : upper(coalesce(v.direction, "ingress"))
      network        = coalesce(v.network_name, v.network, "default")
      action         = upper(coalesce(v.action, v.allow != null ? "ALLOW" : (v.deny != null ? "DENY" : "ALLOW")))
      ports          = coalesce(v.ports, v.port != null ? [v.port] : [])
      protocols      = coalesce(v.protocols, v.protocol != null ? [v.protocol] : ["all"])
    })
  ]
}

# Generate 5-character random strings for firewall rules that don't have any name fields
resource "random_string" "short_name" {
  for_each = { for i, v in local._firewall_rules : i => true if v.gen_short_name }
  length   = 5
  special  = false
  upper    = false
}
locals {
  __firewall_rules = [for i, v in local._firewall_rules :
    merge(v, {
      range_types = toset(coalesce(v.range_types, v.range_type != null ? [v.range_type] : []))
    })
  ]
}
locals {
  range_types = toset(flatten([for i, v in local.__firewall_rules : v.range_types]))
}
data "google_netblock_ip_ranges" "default" {
  for_each   = local.range_types
  range_type = each.value
}

locals {
  ___firewall_rules = [for i, v in local.__firewall_rules :
    merge(v, {
      name                    = lower(trimspace((coalesce(v.name, "fwr-${i}")))
      network_link            = "projects/${v.project_id}/global/networks/${v.network}"
      source_tags             = v.direction == "INGRESS" ? v.source_tags : null
      source_service_accounts = v.direction == "INGRESS" ? v.source_service_accounts : null
      source_ranges = v.direction == "INGRESS" ? coalesce(
        v.source_ranges,
        v.ranges,
        flatten([for rt in v.range_types : try(data.google_netblock_ip_ranges.default[rt].cidr_blocks, null)]),
      ) : null
      destination_ranges = v.direction == "EGRESS" ? coalesce(
        v.destination_ranges,
        v.ranges,
        flatten([for rt in v.range_types : try(data.google_netblock_ip_ranges.default[rt].cidr_blocks, null)]),
      ) : null
      traffic = coalesce(
        v.action == "ALLOW" ? v.allow : null,
        v.action == "DENY" ? v.deny : null,
        [for protocol in v.protocols :
          {
            protocol = lower(protocol)
            ports    = v.ports
          }
        ],
      )
      rule_description_fields = [
        v.network,
        v.priority,
        substr(lower(v.direction), 0, 1),
        substr(lower(v.action), 0, 1),
        length(v.ports) > 0 ? join("-", slice(v.ports, 0, length(v.ports) == 1 ? 1 : 2)) : "allports", # only use first two ports to keep string size small
      ]
    })
  ]
  firewall_rules = [for i, v in local.___firewall_rules :
    merge(v, {
      # If no IP ranges, use 169.254.169.254 since allowing 0.0.0.0/0 may not be intended
      source_ranges      = v.direction == "INGRESS" ? coalescelist(v.source_ranges, ["169.254.169.254"]) : null
      destination_ranges = v.direction == "EGRESS" ? coalescelist(v.destination_ranges, ["169.254.169.254"]) : null
      key                = "${v.project_id}:${v.name}"
    }) if v.create
  ]
}


resource "google_compute_firewall" "default" {
  for_each                = { for i, v in local.firewall_rules : v.key => v }
  project                 = each.value.project_id
  name                    = each.value.name
  description             = each.value.description
  network                 = each.value.network
  priority                = each.value.priority
  direction               = each.value.direction
  disabled                = each.value.disabled
  source_ranges           = each.value.source_ranges
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  destination_ranges      = each.value.destination_ranges
  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.traffic : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.traffic : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
}

