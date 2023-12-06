
locals {
  subnet_prefix = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region}/subnetworks"
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries" {
  for_each = { for z in var.zones : "${var.name_prefix}-${z}" => "${var.region}-${z}" }
  source   = "github.com/PaloAltoNetworks/terraform-google-vmseries-modules//modules/vmseries"
  project  = var.project_id
  name     = each.key
  zone     = each.value #"${var.region}-${each.key}"
  ssh_keys = var.ssh_keys
  #vmseries_image          = null
  create_instance_group   = false
  metadata                = {}
  metadata_startup_script = null
  named_ports             = []
  service_account         = null
  bootstrap_options       = {}

  network_interfaces = [
    for subnet_name in var.subnet_names :
    {
      subnetwork = "${local.subnet_prefix}/${subnet_name}"
      #private_ip = null
    }
  ]
}

