output "healthchecks" {
  value = [for i, v in local.healthchecks :
    {
      name   = v.name
      region = v.region
      id = one(coalesce(
        v.is_regional && !v.is_legacy ? try(google_compute_region_health_check.default[v.key].id, null) : null,
        !v.is_regional && !v.is_legacy ? try(google_compute_health_check.default[v.key].id, null) : null,
        v.is_legacy && v.is_http ? try(google_compute_http_health_check.default[v.key].id, null) : null,
        v.is_legacy && v.is_http ? try(google_compute_https_health_check.default[v.key].id, null) : null,
      ))
    }
  ]
}
