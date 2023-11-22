variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "dns_zones" {
  description = "List of DNS zones"
  type = list(object({
    create            = optional(bool, true)
    project_id        = optional(string)
    dns_name          = string
    name              = optional(string)
    description       = optional(string)
    visibility        = optional(string)
    visible_networks  = optional(list(string))
    peer_project_id   = optional(string)
    peer_network_name = optional(string)
    logging           = optional(bool)
    force_destroy     = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = optional(string)
      forwarding_path = optional(string)
    })))
    records = optional(list(object({
      create  = optional(bool, true)
      name    = string
      type    = optional(string)
      ttl     = optional(number)
      rrdatas = list(string)
    })))
  }))
  default = []
}
variable "dns_policies" {
  description = "List of DNS Policies"
  type = list(object({
    create                    = optional(bool, true)
    project_id                = optional(string)
    name                      = optional(string)
    description               = optional(string)
    logging                   = optional(bool)
    enable_inbound_forwarding = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = optional(string)
      forwarding_path = optional(string)
    })))
    networks = optional(list(string))
  }))
  default = []
}

