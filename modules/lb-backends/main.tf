locals {
  _backend_buckets = [for i, v in local.backends :
    {
      create      = coalesce(v.create, true)
      project_id  = coalesce(v.project_id, var.project_id)
      name        = lower(trimspace(coalesce(v.name, "backend-bucket-{$i}")))
      enable_cdn  = coalesce(v.enable_cdn, true) # This is probably static content, so why not?
    }
  ]
  backend_buckets = [for i, v in local._backend_buckets :
    merge(v, {
      bucket_name = coalesce(v.bucket_name, v.name, "bucket-${v.name}")
      description = coalesce(v.description, "Backend Bucket '${v.name}'")
      key_index = "${v.project_id}/${v.name}"
    }) if v.create == true
  ]
}

# Backend Buckets
resource "google_compute_backend_bucket" "default" {
  for_each    = { for i, v in local.backend_buckets : v.key_index => v }
  project     = each.value.project_id
  name        = each.value.name
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn
}
