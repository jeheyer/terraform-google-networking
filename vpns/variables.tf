variable "project_id" {
  description = "Project ID of GCP Project"
  type        = string
}
variable "region" {
  description = "Name of the GCP Region"
  type        = string
}
variable "cloud_router" {
  description = "Name of the Cloud Router"
  type        = string
  default     = null
}
variable "cloud_vpn_gateway" {
  description = "Name of the Cloud VPN Gateway"
  type        = string
  default     = null
}
variable "network" {
  description = "Name of the Network attached to Cloud VPN Gateway & Cloud Router"
  type        = string
  default     = "default"
}
variable "tunnel_range" {
  description = "IP Prefix to use for tunnel interfaces (i.e. 169.254.42.80/28)"
  type        = string
  default     = null
}
variable "peer_bgp_asn" {
  type    = number
  default = 65000
}
variable "advertised_priority" {
  type    = number
  default = 100
}
variable "advertised_ip_ranges" {
  type    = list(string)
  default = []
}
variable "peer_set" {
  description = "Settings for External (Peer) VPN Gateways"
  type = object({
    name        = string
    description = optional(string)
    peers = list(object({
      name                = string
      ip_address          = string
      shared_secret       = optional(string)
      advertised_priority = optional(number)
      cloud_router_ip     = optional(string)
      bgp_ip              = optional(string)
      bgp_asn             = optional(number)
      bgp_name            = optional(string)
      interface_index     = optional(number)
      interface_name      = optional(string)
    }))
  })
}
