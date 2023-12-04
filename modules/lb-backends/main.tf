locals {
  _backend_buckets = [for i, v in var.backends :
    {
      create     = coalesce(v.create, true)
      project_id = coalesce(v.project_id, var.project_id)
      name       = lower(trimspace(coalesce(v.name, "backend-bucket-{$i}")))
      enable_cdn = coalesce(v.enable_cdn, true) # This is probably static content, so why not?
    }
  ]
  backend_buckets = [for i, v in local._backend_buckets :
    merge(v, {
      bucket_name = coalesce(v.bucket_name, v.name, "bucket-${v.name}")
      description = coalesce(v.description, "Backend Bucket '${v.name}'")
      index_key   = "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}

# Backend Buckets
resource "google_compute_backend_bucket" "default" {
  for_each    = { for i, v in local.backend_buckets : v.index_key => v }
  project     = each.value.project_id
  name        = each.value.name
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn
}


locals {
  _backend_services = flatten([for i, v in var.backends :
    merge(v, {
      description = coalesce(v.description, "Backend Service '${v.name}'")
    })
  ])
  backend_services = [for i, v in local._backend_services :
    merge(v, {
      index_key = v.is_regional ? "${v.project_id}/${v.region}/${v.name}" : "${v.project_id}/${v.name}"
    })
  ]
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  for_each                        = { for i, v in local.backend_services : v.index_key => v if v.is_global }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = each.value.load_balancing_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.protocol
  port_name                       = each.value.port_name
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.healthchecks
  session_affinity                = each.value.session_affinity_type
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  custom_request_headers          = each.value.custom_request_headers
  custom_response_headers         = each.value.custom_response_headers
  security_policy                 = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.balancing_mode
      max_rate_per_instance = each.value.max_rate_per_instance
      max_utilization       = each.value.max_utilization
      max_connections       = each.value.max_connections
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  /*
  dynamic "iap" {
    for_each = each.value.use_iap ? [true] : []
    content {
      oauth2_client_id     = google_iap_client.default[each.key].client_id
      oauth2_client_secret = google_iap_client.default[each.key].secret
    }
  }
  */
  enable_cdn = each.value.enable_cdn
  dynamic "cdn_policy" {
    for_each = each.value.enable_cdn == true ? [true] : []
    content {
      cache_mode                   = each.value.cdn_cache_mode
      signed_url_cache_max_age_sec = 3600
      default_ttl                  = each.value.cdn_default_ttl
      client_ttl                   = each.value.cdn_client_ttl
      max_ttl                      = each.value.cdn_max_ttl
      negative_caching             = false
      cache_key_policy {
        include_host           = true
        include_protocol       = true
        include_query_string   = true
        query_string_blacklist = []
        query_string_whitelist = []
      }
    }
  }
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  for_each                        = { for i, v in local.backend_services : v.index_key => v if !v.is_global }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = each.value.load_balancing_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.protocol
  port_name                       = each.value.port_name
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.healthchecks
  session_affinity                = each.value.session_affinity_type
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.balancing_mode
      max_rate_per_instance = each.value.max_rate_per_instance
      max_utilization       = each.value.max_utilization
      max_connections       = each.value.max_connections
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.sample_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  region = each.value.region
}
