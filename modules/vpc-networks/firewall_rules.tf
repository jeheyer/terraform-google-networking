locals {
  firewall_rules = flatten(
    [for vpc_network in local.vpc_networks :
      [for i, v in coalesce(vpc_network.firewall_rules, []) :
        merge(v, {
          project_id   = coalesce(v.project_id, var.project_id)
          network_name = vpc_network.name
        })
      ]
    ]
  )
}

module "firewall-rules" {
  source         = "git::https://github.com/jeheyer/terraform-google-networking//modules/firewall"
  project_id     = var.project_id
  firewall_rules = local.firewall_rules
}
