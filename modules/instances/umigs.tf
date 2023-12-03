locals {
  _umigs = flatten(concat(
    [for i, v in var.umigs :
      merge(v, {
        create             = coalesce(v.create, true)
        project_id         = coalesce(v.project_id, var.project_id)
        network_project_id = coalesce(v.network_project_id, var.network_project_id, v.project_id, var.project_id)
        name               = lower(trimspace(coalesce(v.name, "umig-${i + 1}")))
        network            = coalesce(v.network_name, v.network, "default")
        named_ports        = coalesce(v.named_ports, [])
      })
    ],
    [for i, v in local.instances :
      merge(v, {
        create             = coalesce(v.create, true)
        project_id         = coalesce(v.project_id, var.project_id)
        network_project_id = coalesce(v.network_project_id, var.network_project_id, v.project_id, var.project_id)
        name               = v.name
        network            = coalesce(v.network_name, v.network, "default")
        zone               = v.zone
        instances          = [v.name]
      }) if v.create_umig
    ]
  ))
  umigs = [for i, v in local._umigs :
    merge(v, {
      network      = "https://www.googleapis.com/compute/v1/projects/${v.network_project_id}/global/networks/${v.network}"
      zones_prefix = "projects/${v.project_id}/zones/${v.zone}"
      key          = "${v.project_id}:${v.zone}:${v.name}"
    }) if v.create
  ]
}

# Unmanaged Instance Groups
resource "google_compute_instance_group" "default" {
  for_each  = { for i, v in local.umigs : v.key => v }
  project   = each.value.project_id
  name      = each.value.name
  network   = each.value.network
  zone      = each.value.zone
  instances = formatlist("${each.value.zones_prefix}/instances/%s", each.value.instances)
  # Also do named ports within the instance group
  dynamic "named_port" {
    for_each = each.value.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
  depends_on = [google_compute_instance.default]
}

