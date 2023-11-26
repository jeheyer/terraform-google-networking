locals {
  region                 = "us-central1"
  machine_type           = "e2-micro"
  os_project             = "debian-cloud"
  os                     = "debian-11"
  service_account_scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
  zones                  = ["b", "c", "a"]
}
