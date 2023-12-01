variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "firewall_rules" {
  description = "List of Firewall Rules"
  type = list(object({
    create                  = optional(bool, true)
    project_id              = optional(string)
    name                    = optional(string)
    name_prefix             = optional(string)
    short_name              = optional(string)
    description             = optional(string)
    network                 = optional(string)
    network_name            = optional(string)
    priority                = optional(number)
    logging                 = optional(bool)
    direction               = optional(string)
    ranges                  = optional(list(string))
    range                   = optional(string)
    source_ranges           = optional(list(string))
    destination_ranges      = optional(list(string))
    range_types             = optional(list(string))
    range_type              = optional(string)
    protocol                = optional(string)
    protocols               = optional(list(string))
    port                    = optional(number)
    ports                   = optional(list(number))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    action                  = optional(string)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    enforcement = optional(bool)
    disabled    = optional(bool)
  }))
  default = []
}
variable "firewall_policies" {
  description = "List of Firewall Policies"
  type = list(object({
    create     = optional(bool, true)
    project_id = optional(string)
    name       = optional(string)
  }))
  default = []
}
