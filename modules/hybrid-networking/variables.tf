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
    network_name = optional(string)
    region       = string
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
