locals {
  _ip_addresses = [for i, v in var.forwarding_rules :
    merge(v, {
      is_global   = false
      is_internal = true
      enable_ipv4 = true
      enable_ipv6 = false
      is_managed  = false
    }) if v.create == true || coalesce(v.preserve_ip, false) == true
  ]
  ip_addresses = [for i, v in local._ip_addresses :
    merge(v, {
      ip_versions            = v.is_global ? concat(v.enable_ipv4 ? ["IPV4"] : [], v.enable_ipv6 ? ["IPV6"] : []) : ["IPV4"]
      address_type           = v.is_internal ? "INTERNAL" : "EXTERNAL"
      prefix_length          = v.is_global || v.is_psc ? null : 0
      purpose                = v.is_psc ? "GCE_ENDPOINT" : v.is_managed && v.is_internal ? "SHARED_LOADBALANCER_VIP" : null
      is_mirroring_collector = v.is_internal ? false : null
      network_tier           = v.is_psc ? null : v.network_tier
      address                = v.is_psc ? null : v.address
    })
  ]
}

# Global static IP
resource "google_compute_global_address" "default" {
  for_each     = { for i, v in local.ip_addresses : v.key_index => v if v.is_global }
  project      = each.value.project_id
  name         = each.value.name
  address_type = each.value.address_type
  ip_version   = each.value.ip_version
  address      = each.value.address
}

# Regional static IP
resource "google_compute_address" "default" {
  for_each      = { for i, v in local.ip_addresses : v.key_index => v if !v.is_global }
  project       = each.value.project_id
  name          = each.value.name
  address_type  = each.value.address_type
  ip_version    = each.value.ip_version
  address       = each.value.address
  region        = each.value.region
  subnetwork    = each.value.subnetwork
  network_tier  = each.value.network_tier
  purpose       = each.value.purpose
  prefix_length = each.value.prefix_length
}