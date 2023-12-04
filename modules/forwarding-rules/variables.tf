variable "project_id" {
  description = "GCP Project ID to create resources in"
  type        = string
}
variable "network_project_id" {
  description = "If using Shared VPC, the GCP Project ID for the host network"
  type        = string
  default     = null
}
variable "region" {
  description = "GCP region name for the IP address and forwarding rule"
  type        = string
  default     = null
}
variable "forwarding_rules" {
  description = "List of Forwarding Rules"
  type = list(object({
    create              = optional(bool, true)
    project_id          = optional(string)
    host_project_id     = optional(string)
    region              = optional(string)
    name                = optional(string)
    description         = optional(string)
    network             = optional(string)
    network_id          = optional(string)
    network_name        = optional(string)
    subnet              = optional(string)
    subnet_id           = optional(string)
    subnet_name         = optional(string)
    target              = optional(string)
    target_id           = optional(string)
    target_project_id   = optional(string)
    target_region       = optional(string)
    target_name         = optional(string)
    allow_global_access = optional(string)
    preserve_ip         = optional(bool)
  }))
  default = []
}
