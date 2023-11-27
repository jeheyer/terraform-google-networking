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

variable "service_attachments" {
  description = "Services Published via PSC"
  type = list(object({
    create                   = optional(bool, true)
    project_id               = optional(string)
    name                     = optional(string)
    description              = optional(string)
    region                   = optional(string)
    forwarding_rule_name     = optional(string)
    target_service_id        = optional(string)
    nat_subnet_ids           = optional(list(string))
    nat_subnet_names         = optional(list(string))
    network_project_id       = optional(string)
    enable_proxy_protocol    = optional(bool)
    auto_accept_all_projects = optional(bool)
    accept_project_ids = optional(list(object({
      project_id       = string
      connection_limit = optional(number)
    })))
    consumer_reject_lists = optional(list(string))
    reconcile_connections = optional(bool)
  }))
  default = []
}
