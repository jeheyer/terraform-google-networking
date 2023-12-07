
locals {
  region_codes = {
    northamerica-northeast1 = "nane1"
    northamerica-northeast2 = "nane2"
    us-central1             = "usce1"
    us-east1                = "usea1"
    us-east4                = "usea4"
    us-east5                = "usea5"
    us-west1                = "uswe1"
    us-west2                = "uswe2"
    us-west3                = "uswe3"
    us-west4                = "uswe4"
    us-south1               = "usso1"
    europe-west1            = "euwe1"
    europe-west2            = "euwe2"
    europe-west3            = "euwe3"
    europe-west4            = "euwe4"
    australia-southeast1    = "ause1"
    australia-southeast2    = "ause2"
    asia-northeast1         = "asne1"
    asia-northeast2         = "asne2"
    asia-southeast1         = "asse1"
    asia-southeast2         = "asse2"
    asia-east1              = "asea1"
    asia-east2              = "asea2"
    asia-south1             = "asso1"
    asia-south2             = "asso2"
    southamerica-east1      = "saea1"
    me-central1             = "mece1"
  }
  instances = [for i, v in var.deployments :
    {
      name               = coalesce(v.name, "${var.name_prefix}-${try(local.region_codes[v.region], "unknown")}")
      region             = v.region
      zone               = v.zone
      network_name       = var.network_name
      network_project_id = var.network_project_id
      subnet_name        = v.subnet_name
      image              = var.image
      network_tags       = var.network_tags
      machine_type       = coalesce(v.machine_type, var.machine_type)
      startup_script     = "cd tmp; curl -Os https://downloads.thousandeyes.com/agent/install_thousandeyes.sh > install_thousandeyes.sh ; bash ./install_thousandeyes.sh ${var.account_group_token}"
    }
  ]
}

module "instances" {
  source     = "git::https://github.com/jeheyer/terraform-google-networking//modules/instances"
  project_id = var.project_id
  instances  = local.instances
}
