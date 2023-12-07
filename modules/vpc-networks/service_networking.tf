locals {
  _service_connections = flatten([for vpc_network in local.vpc_networks :
    [for i, v in coalesce(vpc_network.service_connections, []) :
      merge(v, {
        create               = coalesce(v.create, true)
        project_id           = coalesce(v.project_id, vpc_network.project_id, var.project_id)
        name                 = coalesce(v.name, "service-networking-${i}")
        service              = lower(coalesce(v.service, "servicenetworking.googleapis.com"))
        network              = google_compute_network.default[vpc_network.index_key].name
        network_id           = google_compute_network.default[vpc_network.index_key].id
        import_custom_routes = coalesce(v.import_custom_routes, false)
        export_custom_routes = coalesce(v.export_custom_routes, false)
        ip_ranges            = v.ip_ranges
      })
    ]
  ])
  service_connections = [for i, v in local._service_connections :
    merge(v, {
      index_key      = "${v.project_id}/${v.network}/${v.service}"
      peering_routes = v.import_custom_routes || v.export_custom_routes ? true : false
    }) if v.create
  ]
}

resource "google_service_networking_connection" "default" {
  for_each                = { for i, v in local.service_connections : v.index_key => v }
  network                 = each.value.network
  service                 = each.value.service
  reserved_peering_ranges = each.value.ip_ranges
  depends_on              = [google_compute_global_address.default]
}

# Separate Step to handle route import/export on peering connections
resource "google_compute_network_peering_routes_config" "default" {
  for_each             = { for i, v in local.service_connections : v.index_key => v if v.peering_routes }
  peering              = google_service_networking_connection.default[each.key].peering
  network              = each.value.network
  import_custom_routes = each.value.import_custom_routes
  export_custom_routes = each.value.export_custom_routes
}
