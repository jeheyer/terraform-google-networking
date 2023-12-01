locals {
  firewall_rules = flatten(
    [for vpc_network in local.vpc_networks :
      [for i, v in coalesce(vpc_network.firewall_rules, []) :
        merge(v, {
          network_name = vpc_network.name
        })
      ]
    ]
  )
}

module "firewall-rules" {
  source         = "git::https://github.com/jeheyer/terraform-google-networking//modules/firewall"
  firewall_rules = local.firewall_rules
}
