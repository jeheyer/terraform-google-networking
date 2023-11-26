locals {
  subnets_0 = flatten([for n in local.vpc_networks :
    [for i, v in coalesce(n.subnets, []) :
      merge(v, {
        create               = coalesce(v.create, true)
        project_id           = coalesce(v.project_id, n.project_id, var.project_id)
        name                 = coalesce(v.name, "subnet-${i}")
        network              = google_compute_network.default[n.key].name
        purpose              = upper(coalesce(v.purpose, "PRIVATE"))
        region               = coalesce(v.region, var.region)
        private_access       = coalesce(v.private_access, var.defaults.subnet_private_access, false)
        aggregation_interval = upper(coalesce(v.log_aggregation_interval, var.defaults.subnet_log_aggregation_interval, "INTERVAL_5_SEC"))
        flow_sampling        = coalesce(v.log_sampling_rate, var.defaults.subnet_log_sampling_rate, 0.5)
        log_metadata         = "INCLUDE_ALL_METADATA"
        flow_logs            = coalesce(v.flow_logs, var.defaults.subnet_flow_logs, false)
        stack_type           = upper(coalesce(v.stack_type, var.defaults.subnet_stack_type, "IPV4_ONLY"))
        attached_projects    = concat(coalesce(v.attached_projects, []), coalesce(n.attached_projects, []))
        shared_accounts      = concat(coalesce(v.shared_accounts, []), coalesce(n.shared_accounts, []))
        secondary_ranges = [for i, r in coalesce(v.secondary_ranges, []) :
          {
            name  = coalesce(r.name, "secondary-range-${i}")
            range = r.range
          }
        ]
      })
    ]
  ])
  subnets = [for i, v in local.subnets_0 :
    merge(v, {
      key                  = "${v.project_id}:${v.region}:${v.name}"
      is_private           = v.purpose == "PRIVATE" ? true : false
      is_proxy_only        = contains(["INTERNAL_HTTPS_LOAD_BALANCER", "REGIONAL_MANAGED_PROXY"], v.purpose) ? true : false
      has_secondary_ranges = length(v.secondary_ranges) > 0 ? true : false
    }) if v.create
  ]
}

resource "google_compute_subnetwork" "default" {
  for_each                 = { for i, v in local.subnets : v.key => v }
  project                  = var.project_id
  name                     = each.value.name
  description              = each.value.description
  network                  = each.value.network
  region                   = each.value.region
  stack_type               = each.value.is_private ? each.value.stack_type : null
  ip_cidr_range            = each.value.ip_range
  purpose                  = each.value.purpose
  role                     = each.value.is_proxy_only ? upper(coalesce(each.value.role, "active")) : null
  private_ip_google_access = each.value.is_private ? each.value.private_access : false
  dynamic "log_config" {
    for_each = each.value.flow_logs && each.value.is_private ? [true] : []
    content {
      aggregation_interval = each.value.aggregation_interval
      flow_sampling        = each.value.flow_sampling
      metadata             = each.value.log_metadata
      metadata_fields      = []
    }
  }
  /* https://github.com/hashicorp/terraform-plugin-sdk/issues/161
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.range
    }
  }
  */
  secondary_ip_range = [for i, v in each.value.secondary_ranges :
    {
      range_name    = v.name
      ip_cidr_range = v.range
    }
  ]
}
