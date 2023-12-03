locals {
  descriptions = {
    "Cluster"   = "CloudGuard Highly Available Security Cluster"
    "AutoScale" = "None"
  }
  _checkpoints = [for i, v in var.checkpoints :
    merge(v, {
      create       = coalesce(v.create, true)
      install_type = coalesce(v.install_type, "Cluster")
    })
  ]
  __checkpoints = [for i, v in local._checkpoints :
    merge(v, {
      is_cluster         = v.install_type == "Cluster" ? true : false
      is_mig             = v.install_type == "AutoScale" ? true : false
      is_management      = length(regexall("Management", v.install_type)) > 0 ? true : false
      is_management_only = startswith(v.install_type, "Management") ? true : false
      is_manual          = startswith(v.install_type, "Manual") ? true : false
    })
  ]
  ___checkpoints = [for i, v in local.__checkpoints :
    merge(v, {
      is_gateway    = v.is_cluster || v.is_mig || length(regexall("Gateway", v.install_type)) > 0 ? true : false
      is_standalone = v.is_cluster || v.is_mig ? false : true
    })
  ]
  ____checkpoints = [for i, v in local.___checkpoints :
    merge(v, {
      install_image = v.is_standalone ? "single" : (v.is_mig ? "mig" : "cluster")
      install_code  = v.is_manual || v.is_management_only ? "" : "${v.install_image}-"
    })
  ]
  checkpoints = [for i, v in local.____checkpoints :
    merge(v, {
      name                     = trim(lower(coalesce(v.name, substr("chkp-${v.install_code}-${v.region}", 0, 16))))
      generate_admin_password  = v.create && v.admin_password == null ? true : false
      generate_sic_key         = v.create && v.sic_key == null ? true : false
      network_project_id       = coalesce(v.network_project_id, var.network_project_id, v.project_id, var.project_id)
      create_nic0_external_ips = coalesce(v.create_nic0_external_ips, true)
      create_nic1_external_ips = v.is_gateway ? coalesce(v.create_nic1_external_ips, true) : false
    }) if v.create == true
  ]
}

# If Admin password not provided, create random 16 character one
resource "random_string" "admin_password" {
  count   = local.generate_admin_password ? 1 : 0
  length  = 16
  special = false
}

# If SIC key not provided, create random 8 character one
resource "random_string" "sic_key" {
  count   = local.generate_sic_key ? 1 : 0
  length  = 8
  special = false
}

locals {
  instance_suffixes  = coalesce(var.instance_suffixes, local.is_cluster ? ["member-a", "member-b"] : ["gateway"])
  instance_zones     = coalesce(var.zones, ["b", "c"])
  nic0_address_names = local.is_cluster ? ["primary-cluster", "secondary-cluster"] : local.instance_suffixes
  address_names = {
    nic0 = local.is_gateway ? [for n in local.nic0_address_names : "${local.name}-${n}"] : [local.name]
    nic1 = local.is_gateway ? [for n in local.instance_suffixes : "${local.name}-${n}"] : ["${local.name}-2"]
  }
  # Create a list of objects for the instances so it's easier to iterate over
  instances = [for i, v in local.instance_suffixes : {
    name              = local.is_standalone ? local.name : "${local.name}-${v}"
    zone              = "${var.region}-${local.instance_zones[i]}"
    nic0_address_name = "${local.address_names["nic0"][i]}-address"
    nic1_address_name = "${local.address_names["nic1"][i]}-nic1-address"
    }
  ]
}

locals {
  nic0_external_ips = [for i, v in local.checkpoint_instances :
    {
      project = v.project_id
      region  = v.region
      name    = nic0_address_name
    } if v.create_nic0_external_ips == true
  ]
}

# Create External Addresses to assign to nic0
resource "google_compute_address" "nic0_external_ips" {
  for_each     = { for i, v in local.nic0_external_ips : "${project_id}:${region}:${name}" => v }
  project      = each.value.project_id
  name         = each.value.name
  region       = each.value.region
  address_type = "EXTERNAL"
}

# For clusters, get status of the the primary and secondary addresses so we don't lose them after configuration
data "google_compute_address" "nic0_external_ips" {
  for_each = { for i, v in local.nic0_external_ips : "${project_id}:${region}:${name}" => v }
  project  = each.value.project_id
  name     = each.value.name
  region   = each.value.region
}

locals {
  nic1_external_ips = [for i, v in local.checkpoint_instances :
    {
      project = v.project_id
      region  = v.region
      name    = nic.external_ip_name
    } if v.create_nic1_external_ips == true
  ]
}
# Create External Addresses to assign to nic0
resource "google_compute_address" "nic1_external_ips" {
  for_each     = { for i, v in local.nic1_external_ips : "${project_id}:${region}:${name}" => v }
  project      = each.value.project_id
  name         = each.value.name
  region       = each.value.region
  address_type = "EXTERNAL"
}

# Locals related to the instances
locals {
  machine_type     = coalesce(var.machine_type, "n1-standard-4")
  network_tags     = coalescelist(var.network_tags, local.is_gateway ? ["checkpoint-gateway"] : ["checkpoint-management"])
  labels           = coalesce(var.labels, {})
  disk_type        = coalesce(var.disk_type, "pd-ssd")
  disk_size        = coalesce(var.disk_size, 100)
  disk_auto_delete = coalesce(var.disk_auto_delete, true)
  service_account_scopes = coalescelist(
    var.service_account_scopes,
    concat(
      ["https://www.googleapis.com/auth/monitoring.write"],
      local.is_gateway ? ["https://www.googleapis.com/auth/compute", "https://www.googleapis.com/auth/cloudruntimeconfig"] : []
    )
  )
  software_version  = coalesce(v.software_version, "R81.10")
  software_code     = lower(replace(v.software_version, ".", ""))
  template_name     = v.is_cluster ? "${lower(v.install_type)}_tf" : "single_tf"
  license_type      = lower(coalesce(v.license_type, "BYOL"))
  checkpoint_prefix = "projects/checkpoint-public/global/images/check-point-${v.software_code}"
  image_type        = v.is_gateway ? "-gw" : ""
  image_prefix      = "${local.checkpoint_prefix}${v.image_type}-${v.license_type}"
  image_versions = {
    "R81.20" = "631-${v.is_manual || v.is_management_only ? "991001243-v20230112" : "991001245-v20230117"}"
    "R81.10" = "335-${v.is_manual || v.is_management_only ? "991001174-v20221110" : "991001234-v20230117"}"
    "R81"    = "392-${v.is_manual || v.is_management_only ? "991001174-v20221108" : "991001234-v20230117"}"
    "R80.40" = "294-${v.is_manual || v.is_management_only ? "991001174-v20221107" : "991001234-v20230117"}"
  }
  image_version         = lookup(v.image_versions, v.software_version, "error")
  default_image         = "${local.image_prefix}-${local.install_code}${local.image_version}"
  image                 = coalesce(v.software_image, v.default_image)
  template_version      = "20230117"
  startup_script_file   = local.is_management_only ? "cloud-config.sh" : "startup-script.sh"
  admin_password        = local.generate_admin_password ? random_string.admin_password[0].result : var.admin_password
  sic_key               = local.generate_sic_key ? random_string.sic_key[0].result : var.sic_key
  allow_upload_download = coalesce(var.allow_upload_download, false)
  enable_monitoring     = coalesce(var.enable_monitoring, false)
  admin_shell           = coalesce(var.admin_shell, "/etc/cli.sh")
  subnet_prefix         = "projects/${var.project_id}/regions/${var.region}/subnetworks"
  network_names         = coalesce(var.network_names, [var.network_name])
  subnet_names          = coalesce(var.subnet_names, [var.subnet_name])
  description = coalesce(v.description, lookup(local.descriptions, v.install_type, "Check Point Security Gateway"))
}

# Create Compute Engine Instances
resource "google_compute_instance" "default" {
  count                     = local.create ? length(local.instances) : 0
  project                   = each.value.project_id
  name                      = each.value.name
  description               = each.value.description
  zone                      = each.value.zone
  machine_type              = each.value.machine_type
  labels                    = each.value.labels
  tags                      = each.value.network_tags
  can_ip_forward            = each.value.is_gateway ? true : false
  allow_stopping_for_update = true
  resource_policies         = []
  boot_disk {
    auto_delete = false
    device_name = "${each.value.name}-boot"
    initialize_params {
      type  = each.value.disk_type
      size  = each.value.disk_size
      image = each.value.image
    }
  }
  # eth0 / nic0
  network_interface {
    network            = each.value.nics[0].network_name
    subnetwork_project = each.value.nics[0].network_project_id
    subnetwork         = each.value.nics[0].subnet_name
    dynamic "access_config" {
      for_each = each.value.create_nic0_external_ips && (local.is_cluster ? data.google_compute_address.nic0_external_ips[count.index].status == "IN_USE" : true) ? [true] : []
      content {
        nat_ip = google_compute_address.nic0_external_ips[count.index].address
      }
    }
  }
  # eth1 / nic1
  dynamic "network_interface" {
    for_each = local.is_gateway ? [true] : []
    content {
      network            = local.network_names[1]
      subnetwork_project = var.project_id
      subnetwork         = "${local.subnet_prefix}/${local.subnet_names[1]}"
      dynamic "access_config" {
        for_each = local.create_nic1_external_ips ? [true] : []
        content {
          nat_ip = google_compute_address.nic1_external_ips[count.index].address
        }
      }
    }
  }
  # Internal interfaces (eth2-8 / nic2-8)
  dynamic "network_interface" {
    for_each = each.value.is_gateway ? slice(local.network_names, 2, length(local.network_names)) : []
    content {
      network            = network_interface.value
      subnetwork_project = each.value.network_project_id
      subnetwork         = "${local.subnet_prefix}/${local.subnet_names[network_interface.key + 2]}"
    }
  }
  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }
  metadata = {
    instanceSSHKey              = each.value.admin_ssh_key
    adminPasswordSourceMetadata = each.value.is_management_only ? null : each.value.admin_password
  }
  metadata_startup_script = each.value.is_manual ? null : templatefile("${path.module}/${each.value.startup_script_file}", {
    // script's arguments
    generatePassword               = each.value.is_management_only ? "false" : "true"
    config_url                     = "https://runtimeconfig.googleapis.com/v1beta1/projects/${var.project_id}/configs/${local.name}-config"
    config_path                    = "projects/${each.value.project_id}/configs/${each.value.name}-config"
    sicKey                         = each.value.sic_key
    allowUploadDownload            = each.value.allow_upload_download
    templateName                   = each.value.template_name
    templateVersion                = each.value.template_version
    templateType                   = "terraform"
    mgmtNIC                        = each.value.is_management ? "Private IP (eth0)" : "Private IP (eth1)"
    hasInternet                    = "true"
    enableMonitoring               = each.value.enable_monitoring
    shell                          = each.value.admin_shell
    installationType               = each.value.install_type
    installSecurityManagement      = each.value.is_management ? "true" : "false"
    computed_sic_key               = each.value.sic_key
    managementGUIClientNetwork     = coalesce(var.allowed_gui_clients, "0.0.0.0/0") # Controls access GAIA web interface
    primary_cluster_address_name   = each.value.is_cluster ? each.value.primary_cluster_address_name : ""
    secondary_cluster_address_name = each.value.is_cluster ? each.value.secondary_cluster_address_name : ""
    managementNetwork              = each.value.is_management ? "" : coalesce(each.value.sic_address, "192.0.2.132/32")

    /* TODO - Need to add these parameters to bash startup script
    domain_name = var.domain_name
    expert_password                = var.expert_password
    proxy_host = var.proxy_host
    proxy_port = coalesce(var.proxy_port, 8080)
    mgmt_routes = coalesce(var.mgmt_routes, "199.36.53.8/30")
    internal_routes =  coalesce(var.internal_routes, "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16")
    */
  })
}

# Unmanaged Instance Group for each gateway
resource "google_compute_instance_group" "default" {
  for_each = { for i, v in local.checkpoint_instances : v.key => v if v.create_instance_groups == true }
  project     = each.value.project_id
  name        = each.value.name
  description = "Unmanaged Instance Group for ${each.value.name}"
  network     = "projects/${each.value.network_project_id}/global/networks/${each.value.nics[0].network_name}"
  instances   = [google_compute_instance.default[v.key].self_link]
  zone        = each.value.zone
}
