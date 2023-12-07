
locals {
  instances = [for i, v in var.deployments :
    {
      name               = v.name
      name_prefix        = var.name_prefix
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
