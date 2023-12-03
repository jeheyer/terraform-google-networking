locals {
  _peerings = flatten([for n in local.vpc_networks :
    [for i, v in coalesce(n.peerings, []) :
      merge(v, {
        create            = coalesce(v.create, true)
        project_id        = coalesce(v.project_id, n.project_id, var.project_id)
        name              = coalesce(v.name, "peering-${i}")
        peer_project_id   = coalesce(v.peer_project_id, v.project_id, n.project_id, var.project_id)
        peer_network_name = coalesce(v.peer_network_name, "default")
        network_name      = n.name
      })
    ]
  ])
  peerings = [for i, v in local._peerings :
    merge(v, {
      # If peer network link not provided, we can generate it using their project ID and network name
      network      = "projects/${v.project_id}/global/networks/${v.network_name}"
      peer_network = coalesce(v.peer_network_link, "projects/${v.peer_project_id}/global/networks/${v.peer_network_name}")
      index_key    = "${v.project_id}/${v.network_name}/${v.name}"
    }) if v.create == true
  ]
}

resource "google_compute_network_peering" "default" {
  for_each                            = { for k, v in local.peerings : v.index_key => v }
  name                                = each.value.name
  network                             = each.value.network
  peer_network                        = each.value.peer_network
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  depends_on                          = [google_compute_network.default]
}