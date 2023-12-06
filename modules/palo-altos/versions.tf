terraform {
  required_version = ">= 1.3.2"
  required_providers {
    google = ">= 3.88, < 5.0"
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-vm:compute_instance/v8.0.0"
  }
}


#provider "panos" {
#  hostname         = "127.0.0.1"
#  json_config_file = "../panos-creds.json"
#}


#provider "checkpoint" {
#  server   = "10.194.18.234"
#  username = "jheyer.lab"
#  password = "asdf"
#  context  = "web_api"
#}

provider "google" {
  project = var.project_id
  region  = var.region
}