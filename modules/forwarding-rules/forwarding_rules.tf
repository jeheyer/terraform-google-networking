locals {
  _forwarding_rules = [for i, v in var.forwarding_rules :
    {
      create      = coalesce(v.create, true)
      project_id  = coalesce(v.project_id, var.project_id)
      description = coalesce(v.description, "Managed by Terraform")
      region      = try(coalesce(v.region, var.region), null)
      ports       = length(coalesce(v.ports, [])) > 0 ? v.ports : null
      network     = coalesce(try(v.network, "name", null), "default")
      labels      = { for k, v in coalesce(v.labels, {}) : k => lower(replace(v, " ", "_")) }
      ip_protocol = v.ports != null || v.all_ports ? "TCP" : "HTTP"
      is_psc      = false
    } if v.create == true || coalesce(v.preserve_ip, false) == true
  ]
  __forwarding_rules = [for i, v in local._forwarding_rules :
    merge(v, {
      is_global   = try(coalesce(v.region, v.subnet, v.subnet_id), null) == null ? true : false
      is_internal = try(coalesce(v.subnet, v.subnet_id, v.subnet_name), null) == null ? true : false
    })
  ]
  forwarding_rules = [for i, v in local.__forwarding_rules :
    merge(v, {
      allow_global_access   = v.is_internal ? coalesce(v.allow_global_access, false) : false
      index_key             = v.is_global ? "${v.project_id}/${v.name}" : "${v.project_id}/${v.region}/${v.name}"
      load_balancing_scheme = v.is_internal ? "INTERNAL" : "EXTERNAL"
      network_tier          = v.is_managed && !v.is_internal ? "STANDARD" : null
      subnetwork            = v.is_psc ? null : v.subnetwork
      load_balancing_scheme = v.is_psc ? "" : v.load_balancing_scheme
      all_ports             = v.is_psc ? false : v.all_ports
      target                = v.is_global ? v.target : null
    }) if v.create == true
  ]
}

# Global Forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  for_each   = { for i, v in local.forwarding_rules : v.key_index => v if v.is_global }
  project    = each.value.project_id
  name       = each.value.name
  port_range = each.value.port_range
  #ports                 = each.value.ports
  target                = each.value.target
  ip_address            = each.value.ip_address
  load_balancing_scheme = each.value.load_balancing_scheme
  labels                = each.value.labels
  ip_protocol           = each.value.ip_protocol
  depends_on            = [google_compute_global_address.default]
}

# Regional Forwarding rule
resource "google_compute_forwarding_rule" "default" {
  for_each               = { for i, v in local.forwarding_rules : v.key_index => v if !v.is_global }
  project                = each.value.project_id
  name                   = each.value.name
  port_range             = each.value.port_range
  ports                  = each.value.ports
  all_ports              = each.value.all_ports
  backend_service        = each.value.backend_service
  target                 = null
  ip_address             = each.value.ip_address
  load_balancing_scheme  = each.value.load_balancing_scheme
  labels                 = each.value.labels
  is_mirroring_collector = each.value.is_mirroring_collector
  network                = each.value.network
  region                 = each.value.region
  subnetwork             = each.value.subnetwork
  network_tier           = each.value.network_tier
  allow_global_access    = each.value.allow_global_access
  depends_on             = [google_compute_address.default]
}
