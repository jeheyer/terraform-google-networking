output "healthchecks" {
  value = [for i, v in local.healthchecks :
    {
      name   = v.name
      region = v.region
      id = coalesce(
        v.is_regional && !v.is_legacy ? google_compute_region_health_check.default[v.index_key].id : null,
        !v.is_regional && !v.is_legacy ? google_compute_health_check.default[v.index_key].id : null,
        v.is_legacy && v.is_http ? google_compute_http_health_check.default[v.index_key].id : null,
        v.is_legacy && v.is_https ? google_compute_https_health_check.default[v.index_key].id : null,
        "unknown"
      )
    }
  ]
}
