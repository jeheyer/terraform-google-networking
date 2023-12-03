locals {
  _healthchecks = [for i, v in var.healthchecks :
    merge(v, {
      create       = coalesce(v.create, true)
      project_id   = coalesce(v.project_id, var.project_id)
      name         = v.name != null ? trimspace(lower(v.name)) : null
      protocol     = upper(coalesce(v.protocol, "tcp"))
      proxy_header = coalesce(v.proxy_header, "NONE")
    })
  ]
}

# If no name yet, generate a random one
resource "random_string" "names" {
  for_each = { for i, v in local._healthchecks : i => true if v.name == null }
  length   = 8
  lower    = true
  upper    = false
  special  = false
  numeric  = false
}

locals {
  __healthchecks = [for i, v in local._healthchecks :
    merge(v, {
      name         = coalesce(v.name, v.name == null ? random_string.names[i].result : "error")
      request_path = startswith(v.protocol, "HTTP") ? coalesce(v.request_path, "/") : null
      response     = startswith(v.protocol, "HTTP") ? coalesce(v.response, "OK") : null
      is_regional  = v.region != null ? true : false
      is_legacy    = v.legacy == true ? true : false
      is_tcp       = v.protocol == "TCP" ? true : false
      is_http      = v.protocol == "HTTP" ? true : false
      is_https     = v.protocol == "HTTPS" ? true : false
      is_ssl       = v.protocol == "SSL" ? true : false
    })
  ]
  healthchecks = [for i, v in local.__healthchecks :
    merge(v, {
      index_key = v.is_regional ? "${v.project_id}/${v.region}/${v.name}" : "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}

# Regional Health Checks
resource "google_compute_region_health_check" "default" {
  for_each    = { for i, v in local.healthchecks : v.index_key => v if v.is_regional && !v.is_legacy }
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  dynamic "tcp_health_check" {
    for_each = each.value.is_tcp ? [true] : []
    content {
      port         = each.value.port
      proxy_header = each.value.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = each.value.is_http ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "https_health_check" {
    for_each = each.value.is_https ? [true] : []
    content {
      port         = each.value
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = each.value.is_ssl ? [true] : []
    content {
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  check_interval_sec  = each.value.interval
  timeout_sec         = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  log_config {
    enable = each.value.logging
  }
}

# Global Health Checks
resource "google_compute_health_check" "default" {
  for_each    = { for i, v in local.healthchecks : v.index_key => v if !v.is_regional && !v.is_legacy }
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
  dynamic "tcp_health_check" {
    for_each = each.value.is_tcp ? [true] : []
    content {
      port         = each.value.port
      proxy_header = each.value.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = each.value.is_http ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "https_health_check" {
    for_each = each.value.is_https ? [true] : []
    content {
      port         = each.value
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = each.value.is_ssl ? [true] : []
    content {
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  check_interval_sec  = each.value.interval
  timeout_sec         = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  log_config {
    enable = each.value.logging
  }
}


# Legacy HTTP Health Check
resource "google_compute_http_health_check" "default" {
  for_each           = { for i, v in local.healthchecks : v.index_key => v if v.is_legacy && v.is_http }
  project            = each.value.project_id
  name               = each.value.name
  description        = each.value.description
  port               = each.value.port
  check_interval_sec = each.value.interval
  timeout_sec        = each.value.timeout
}

# Legacy HTTPS Health Check
resource "google_compute_https_health_check" "default" {
  for_each           = { for i, v in local.healthchecks : v.index_key => v if v.is_legacy && v.is_https }
  project            = each.value.project_id
  name               = each.value.name
  description        = each.value.description
  port               = each.value.port
  check_interval_sec = each.value.interval
  timeout_sec        = each.value.timeout
}
