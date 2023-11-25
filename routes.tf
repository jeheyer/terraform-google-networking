locals {
  routes_0 = flatten([for n in local.vpc_networks :
    [for i, v in coalesce(n.routes, []) :
      merge(v, {
        create        = coalesce(v.create, true)
        project_id    = coalesce(v.project_id, n.project_id, var.project_id)
        name          = replace(coalesce(v.name, "route-${i}"), "_", "-")
        next_hop_type = can(regex("^[1-2]", v.next_hop)) ? "ip" : "instance"
        network       = n.name #google_compute_network.default[n.key].name
        dest_range    = v.dest_range
        dest_ranges   = coalesce(v.dest_ranges, [])
      })
    ]
  ])
  routes = flatten(concat(
    [for r in local.routes_0 :
      # Routes that have more than one destination range
      [for i, dest_range in r.dest_ranges :
        merge(r, {
          name       = "${r.name}-${i}"
          key        = "${r.project_id}:${r.name}:${i}"
          dest_range = dest_range
        })
      ]
    ],
    # Routes with a single destination range
    [for r in local.routes_0 :
      merge(r, {
        key = "${r.project_id}:${r.name}"
      }) if r.dest_range != null
    ]
  ))
}

# Static Routes
resource "google_compute_route" "default" {
  for_each               = { for i, v in local.routes : v.key => v }
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
