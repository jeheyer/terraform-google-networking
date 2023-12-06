locals {
  address_names = flatten([for i, v in local.instances :
    {
      project_id  = v.project_id
      region      = v.region
      name        = v.nat_ip_name
      v.index_key = "${v.project_id}/${v.region}/${v.nat_ip_name}"
    } if v.nat_ip_name != null
  ])
}
data "google_compute_addresses" "address_names" {
  for_each = { for i, v in local.instances : v.index_key => v }
  project  = each.value.project_id
  region   = each.value.region
  filter   = "name:${each.value.name}"
}

locals {
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
