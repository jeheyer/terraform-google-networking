locals {
  region                 = "us-central1"
  machine_type           = "e2-micro"
  os_project             = "debian-cloud"
  os                     = "debian-11"
  service_account_scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
  zones                  = ["b", "c"]
  metadata = {
    enable-osconfig         = "true"
    enable-guest-attributes = "true"
  }
}

# Get a list of available zones for each region
locals {
  regions = toset(flatten(concat(
    [for i, v in local._instances : v.region],
    [for i, v in local._migs : v.region]
  )))
}
data "google_compute_zones" "available" {
  for_each = local.regions
  project  = var.project_id
  region   = each.value
}
