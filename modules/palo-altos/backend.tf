terraform {
  backend "gcs" {
    bucket = "otl-network-tf"
    prefix = "palo_alto"
  }
}
