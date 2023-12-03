variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "region" {
  type        = string
  description = "Default GCP Region Name (can be overridden at resource level)"
  default     = null
}
variable "network_project_id" {
  type        = string
  description = "Default Shared VPC Host Project (can be overridden at resource level)"
  default     = null
}
variable "cloud_vpn_gateways" {
  description = "GCP Cloud VPN Gateways"
  type = list(object({
    create       = optional(bool, true)
    project_id   = optional(string)
    name         = optional(string)
    network      = optional(string)
    network_name = optional(string)
    region       = string
    stack_type   = optional(string)
  }))
  default = []
}
variable "peer_vpn_gateways" {
  description = "Peer (External) VPN Gateways"
  type = list(object({
    create       = optional(bool, true)
    project_id   = optional(string)
    name         = optional(string)
    description  = optional(string)
    ip_addresses = optional(list(string))
    labels       = optional(map(string))
  }))
  default = []
}
variable "vpns" {
  description = "HA VPNs"
  type = list(object({
    create                          = optional(bool, true)
    project_id                      = optional(string)
    name                            = optional(string)
    description                     = optional(string)
    region                          = optional(string)
    cloud_router                    = optional(string)
    cloud_vpn_gateway               = optional(string)
    peer_vpn_gateway                = optional(string)
    peer_gcp_vpn_gateway_project_id = optional(string)
    peer_gcp_vpn_gateway            = optional(string)
    peer_bgp_asn                    = optional(number)
    advertised_priority             = optional(number)
    advertised_groups               = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
    enable_bfd     = optional(bool)
    bfd_multiplier = optional(number)
    tunnels = list(object({
      create               = optional(bool)
      name                 = optional(string)
      interface_index      = optional(number)
      interface_name       = optional(string)
      description          = optional(string)
      ike_version          = optional(number)
      ike_psk              = optional(string)
      cloud_router_ip      = optional(string)
      peer_bgp_name        = optional(string)
      peer_bgp_ip          = optional(string)
      peer_bgp_asn         = optional(number)
      peer_interface_index = optional(number)
      advertised_priority  = optional(number)
      advertised_groups    = optional(list(string))
      advertised_ip_ranges = optional(list(object({
        range       = string
        description = optional(string)
      })))
      enable      = optional(bool)
      enable_bfd  = optional(bool)
      enable_ipv6 = optional(bool)
    }))
  }))
  default = []
}
variable "interconnects" {
  description = "Dedicated and Partner Interconnects"
  type = list(object({
    create              = optional(bool, true)
    project_id          = optional(string)
    type                = string
    region              = optional(string)
    cloud_router        = optional(string)
    cloud_router_ip     = optional(string)
    bgp_peer_ip         = optional(string)
    peer_bgp_asn        = optional(number)
    advertised_priority = optional(number)
    advertised_groups   = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
    mtu            = optional(number)
    enable         = optional(bool)
    enable_bfd     = optional(bool)
    bfd_parameters = optional(list(number))
    circuits = list(object({
      interface_index     = optional(number)
      attachment_name     = optional(string)
      interface_name      = optional(string)
      name                = optional(string)
      bgp_name            = optional(string)
      description         = optional(string)
      mtu                 = optional(number)
      cloud_router_ip     = optional(string)
      bgp_peer_ip         = optional(string)
      peer_bgp_asn        = optional(number)
      advertised_priority = optional(number)
      advertised_groups   = optional(list(string))
      advertised_ip_ranges = optional(list(object({
        range       = string
        description = optional(string)
      })))
    }))
  }))
  default = []
}
variable "defaults" {
  type = object({
    cloud_router_bgp_asn                = optional(number, 64512)
    cloud_router_bgp_keepalive_interval = optional(number, 20)
    vpn_ike_version                     = optional(number, 2)
    vpn_ike_psk_length                  = optional(number, 20)
    vpn_ike_psk                         = optional(string)
  })
  default = {}
}
