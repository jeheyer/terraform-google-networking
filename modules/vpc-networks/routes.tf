locals {
  _routes = flatten([for vpc_network in local.vpc_networks :
    [for i, v in coalesce(vpc_network.routes, []) :
      merge(v, {
        create        = coalesce(v.create, true)
        project_id    = coalesce(v.project_id, vpc_network.project_id, var.project_id)
        name          = lower(trimspace(replace(coalesce(v.name, "route-${i}"), "_", "-")))
        next_hop_type = can(regex("^[1-2]", v.next_hop)) ? "ip" : "instance"
        network       = vpc_network.name
        dest_range    = v.dest_range
        dest_ranges   = coalesce(v.dest_ranges, [])
      })
    ]
  ])
  routes = flatten(concat(
    [for route in local._routes :
      # Routes that have more than one destination range
      [for i, dest_range in route.dest_ranges :
        merge(route, {
          name       = "${route.name}-${i}"
          index_key  = "${route.project_id}/${route.name}/${i}"
          dest_range = dest_range
        })
      ]
    ],
    # Routes with a single destination range
    [for i, v in local._routes :
      merge(v, {
        index_key = "${v.project_id}/${v.name}"
      }) if v.dest_range != null
    ]
  ))
}

# Static Routes
resource "google_compute_route" "default" {
  for_each               = { for i, v in local.routes : v.index_key => v }
  project                = var.project_id
  name                   = each.value.name
  description            = each.value.description
  network                = each.value.network
  dest_range             = each.value.dest_range
  priority               = each.value.priority
  tags                   = each.value.instance_tags
  next_hop_gateway       = each.value.next_hop == null ? "default-internet-gateway" : null
  next_hop_ip            = each.value.next_hop_type == "ip" ? each.value.next_hop : null
  next_hop_instance      = each.value.next_hop_type == "instance" ? each.value.next_hop : null
  next_hop_instance_zone = each.value.next_hop_type == "instance" ? each.value.next_hop_zone : null
  depends_on             = [google_compute_network.default]
}
