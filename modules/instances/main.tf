
locals {
  region                 = "us-central1" # only if neither region nor zone were specified
  machine_type           = "e2-micro"    # because it's the cheapest
  os_project             = "debian-cloud"
  os                     = "debian-11" # GCP default as of 2023
  service_account_scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
  metadata = {
    enable-osconfig         = "true"
    enable-guest-attributes = "true"
  }
}

# Get a list of available zones for each region
locals {
  regions = toset(flatten(concat(
    [for i, v in local._instances : v.region if v.zone == null],
    [for i, v in local._migs : v.region]
  )))
}
data "google_compute_zones" "available" {
  for_each = local.regions
  project  = var.project_id
  region   = each.value
}
