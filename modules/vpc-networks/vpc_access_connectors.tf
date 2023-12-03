locals {
  _vpc_access_connectors = flatten([for vpc_network in local.vpc_networks :
    [for i, v in coalesce(vpc_network.vpc_access_connectors, []) :
      merge(v, {
        create             = coalesce(v.create, true)
        project_id         = coalesce(v.project_id, vpc_network.project_id, var.project_id)
        network_project_id = coalesce(v.network_project_id, v.project_id, vpc_network.project_id, var.project_id)
        name               = coalesce(v.name, "connector-${i}")
        region             = coalesce(v.region, var.region)
        network            = v.subnet_name == null ? vpc_network.name : null
        min_throughput     = coalesce(v.min_throughput, 200)
        max_throughput     = coalesce(v.max_throughput, 1000)
        min_instances      = coalesce(v.min_instances, 2)
        max_instances      = coalesce(v.max_instances, 10)
        machine_type       = coalesce(v.machine_type, "e2-micro")
      })
    ]
  ])
  vpc_access_connectors = [for i, v in local._vpc_access_connectors :
    merge(v, {
      index_key = "${v.project_id}/${v.region}/${v.name}"
    }) if v.create == true
  ]
}

# Serverless VPC Access Connectors
resource "google_vpc_access_connector" "default" {
  for_each      = { for k, v in local.vpc_access_connectors : v.index_key => v }
  project       = var.project_id
  name          = each.value.name
  network       = each.value.network
  region        = each.value.region
  ip_cidr_range = each.value.cidr_range
  dynamic "subnet" {
    for_each = each.value.subnet_name != null && each.value.cidr_range == null ? [true] : []
    content {
      name       = each.value.subnet_name
      project_id = coalesce(each.value.network_project_id, var.project_id)
    }
  }
  min_throughput = each.value.min_throughput
  max_throughput = each.value.max_throughput
  min_instances  = each.value.min_instances
  max_instances  = each.value.max_instances
  machine_type   = each.value.machine_type
  depends_on     = [google_compute_network.default, google_compute_subnetwork.default]
}
