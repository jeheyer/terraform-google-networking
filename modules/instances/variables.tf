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

variable "instances" {
  type = list(object({
    create                 = optional(bool, true)
    project_id             = optional(string)
    network_project_id     = optional(string)
    name                   = optional(string)
    description            = optional(string)
    region                 = string
    zone                   = optional(string)
    network_name           = optional(string)
    subnet_name            = optional(string)
    machine_type           = optional(string)
    boot_disk_type         = optional(string)
    boot_disk_size         = optional(number)
    image                  = optional(string)
    os                     = optional(string)
    os_project             = optional(string)
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string))
    network_tags           = optional(list(string))
    can_ip_forward         = optional(bool)
    delete_protection      = optional(bool)
    nat_ip_addresses       = optional(list(string))
    nat_ip_names           = optional(list(string))
    ssh_key                = optional(string)
    create_instance_groups = optional(bool)
    public_zone            = optional(string)
    private_zone           = optional(string)
  }))
  default = []
}

