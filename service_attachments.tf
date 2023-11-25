locals {
  service_attachments_0 = [for i, v in var.service_attachments :
    merge(v, {
      create                   = coalesce(v.create, true)
      project_id               = coalesce(v.project_id, var.project_id)
      description              = coalesce(v.description, "Managed by Terraform")
      region                   = try(coalesce(v.region, var.region), null)
      reconcile_connections    = coalesce(v.reconcile_connections, true)
      enable_proxy_protocol    = coalesce(v.enable_proxy_protocol, false)
      auto_accept_all_projects = coalesce(v.auto_accept_all_projects, false)
      consumer_reject_lists    = coalesce(v.consumer_reject_lists, [])
      domain_names             = coalesce(v.domain_names, [])
    })
  ]
  service_attachments_1 = [for i, v in local.service_attachments_0 :
    merge(v, {
      network_project_id = coalesce(v.network_project_id, var.network_project_id, v.project_id)
      region             = v.target_service_id != null ? lower(element(split("/", v.target_service_id), 3)) : v.region
      service_name       = v.target_service_id != null ? lower(element(split("/", v.target_service_id), 5)) : v.forwarding_rule_name
      accept_project_ids = [
        for p in coalesce(v.accept_project_ids, []) : {
          project_id       = p.project_id
          connection_limit = coalesce(p.connection_limit, 10)
        }
      ]
      connection_preference = coalesce(v.auto_accept_all_projects, false) ? "ACCEPT_AUTOMATIC" : "ACCEPT_MANUAL"
    }) if v.create
  ]
  service_attachments_2 = [for i, v in local.service_attachments_1 :
    merge(v, {
      name        = coalesce(v.name, v.service_name, "psc-${i}")
      is_global   = v.region == null ? true : false
      is_regional = v.region != null ? true : false
    })
  ]
  service_attachments_3 = [for i, v in local.service_attachments_2 :
    merge(v, {
      sn_prefix = "projects/${v.network_project_id}/regions/${v.region}/subnetworks"
      fr_prefix = "projects/${v.project_id}/regions/${v.region}/forwardingRules"
    }) if v.is_regional
  ]
  service_attachments_4 = [for i, v in local.service_attachments_3 :
    merge(v, {
      nat_subnets = coalesce(v.nat_subnet_ids, [for sn in coalesce(v.nat_subnet_names, []) : "${v.sn_prefix}/${sn}"])
      fwd_rule_id = v.forwarding_rule_name != null ? "${v.fr_prefix}/${v.forwarding_rule_name}" : null
    }) if v.is_regional
  ]
  service_attachments = [for i, v in local.service_attachments_4 :
    merge(v, {
      target_service = v.is_regional ? coalesce(v.target_service_id, v.fwd_rule_id) : null
      key            = v.is_regional ? "${v.project_id}:${v.region}:${v.name}" : null
    })
  ]
}

resource "google_compute_service_attachment" "default" {
  for_each              = { for k, v in local.service_attachments : v.key => v if v.is_regional }
  project               = each.value.project_id
  name                  = each.value.name
  region                = each.value.region
  description           = each.value.description
  enable_proxy_protocol = each.value.enable_proxy_protocol
  nat_subnets           = each.value.nat_subnets
  target_service        = each.value.target_service
  connection_preference = each.value.connection_preference
  dynamic "consumer_accept_lists" {
    for_each = each.value.accept_project_ids
    content {
      project_id_or_num = consumer_accept_lists.value.project_id
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
  consumer_reject_lists = each.value.consumer_reject_lists
  domain_names          = each.value.domain_names
  reconcile_connections = each.value.reconcile_connections
}

