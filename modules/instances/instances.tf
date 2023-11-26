locals {
  instances_0 = [for i, v in var.instances :
    merge(v, {
      create                 = coalesce(v.create, true)
      project_id             = coalesce(v.project_id, var.project_id)
      network_project_id     = coalesce(v.network_project_id, var.network_project_id, v.project_id, var.project_id)
      name                   = lower(trimspace(coalesce(v.name, "instance-${i + 1}")))
      network_name           = coalesce(v.network_name, "default")
      subnet_name            = coalesce(v.subnet_name, "default")
      description            = coalesce(v.description, "Managed by Terraform")
      os_project             = coalesce(v.os_project, local.os_project)
      os                     = coalesce(v.os, local.os)
      machine_type           = coalesce(v.machine_type, local.machine_type)
      can_ip_forward         = coalesce(v.can_ip_forward, false)
      service_account_scopes = coalesce(v.service_account_scopes, local.service_account_scopes)
      region                 = coalesce(v.region, var.region, local.region)
      delete_protection      = coalesce(v.delete_protection, false)
    })
  ]
  instances_1 = [for i, v in local.instances_0 :
    merge(v, {
      image     = coalesce(v.image, "${v.os_project}/${v.os}")
      zone      = coalesce(v.zone, "${v.region}-${local.zones[i]}")
      subnet_id = "projects/${v.network_project_id}/regions/${v.region}/subnetworks/${v.subnet_name}"
    }) if v.create
  ]
  instances = [for i, v in local.instances_1 :
    merge(v, {
      key = "${v.project_id}:${v.zone}:${v.name}"
    }) if v.create
  ]
}

resource "google_compute_instance" "default" {
  for_each            = { for i, v in local.instances : v.key => v }
  name                = each.value.name
  description         = each.value.description
  zone                = each.value.zone
  project             = each.value.project_id
  machine_type        = each.value.machine_type
  can_ip_forward      = each.value.can_ip_forward
  deletion_protection = each.value.delete_protection
  boot_disk {
    initialize_params {
      type  = each.value.boot_disk_type
      size  = each.value.boot_disk_size
      image = each.value.image
    }
  }
  dynamic "network_interface" {
    for_each = each.value.network_name != null && each.value.subnet_name != null ? [true] : []
    content {
      network            = each.value.network_name
      subnetwork_project = each.value.network_project_id
      subnetwork         = each.value.subnet_name
      /* TODO
      dynamic "access_config" {
        for_each = var.nat_interfaces[network_interface.key] == true && length(var.nat_ips) > 0 ? [var.nat_ips[count.index]] : []
        content {
          nat_ip = var.nat_ips[count.index]
        }
      }
      */
    }
  }
  labels = {
    os           = each.value.os
    image        = each.value.image != null ? substr(replace(each.value.image, "/", "-"), 0, 63) : null
    machine_type = each.value.machine_type
  }
  tags                    = each.value.network_tags
  metadata_startup_script = each.value.startup_script
  metadata = each.value.ssh_key != null ? {
    instanceSSHKey = each.value.ssh_key
  } : null
  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }
  allow_stopping_for_update = true
}

