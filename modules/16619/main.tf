
resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in [{}] : "${var.vpn_name}-${i}" => true }
  project                 = var.project_id
  region                  = var.region
  name                    = "router-interface-0"
  router                  = var.router_name
  ip_range                = var.ip_range
  vpn_tunnel              = var.vpn_name
  interconnect_attachment = null
  depends_on              = [google_compute_vpn_tunnel.default]
}

resource "google_compute_router_peer" "default" {
  for_each                  = { for i, v in [{}] : "${var.vpn_name}-${i}" => true }
  project                   = var.project_id
  region                    = var.region
  name                      = "router-peer-0"
  router                    = var.router_name
  interface                 = "router-interface-0"
  peer_ip_address           = var.peer_ip_address
  peer_asn                  = var.peer_asn
  advertised_route_priority = 100
  enable                    = true
  enable_ipv6               = false
  depends_on                = [google_compute_router_interface.default]
}

resource "time_sleep" "delay_vpn_tunnel_destroy" {
  for_each                        = { for i, v in [{}] : "${var.vpn_name}-${i}" => true }
  destroy_duration = "15s"
}

resource "null_resource" "vpn_tunnels" {
  for_each                        = { for i, v in [{}] : "${var.vpn_name}-${i}" => true }
}

resource "google_compute_vpn_tunnel" "default" {
  for_each                        = { for i, v in [{}] : "${var.vpn_name}-${i}" => true }
  project                         = var.project_id
  region                          = var.region
  name                            = var.vpn_name
  router                          = var.router_name
  peer_ip                         = null
  vpn_gateway                     = var.vpn_gateway
  peer_external_gateway           = var.peer_external_gateway
  peer_gcp_gateway                = null
  ike_version                     = 2
  shared_secret                   = var.shared_secret
  vpn_gateway_interface           = 0
  peer_external_gateway_interface = 0
  #depends_on = [time_sleep.delay_vpn_tunnel_destroy]
  #depends_on = [null_resource.vpn_tunnels]
}
