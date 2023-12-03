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
  description = "List of Standalone Instances"
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
    labels                 = optional(map(string))
    can_ip_forward         = optional(bool)
    delete_protection      = optional(bool)
    nat_ip_addresses       = optional(list(string))
    nat_ip_names           = optional(list(string))
    ssh_key                = optional(string)
    create_umig            = optional(bool)
    public_zone            = optional(string)
    private_zone           = optional(string)
  }))
  default = []
}

variable "instance_templates" {
  description = "List of Instance Templates"
  type = list(object({
    create                 = optional(bool, true)
    project_id             = optional(string)
    network_project_id     = optional(string)
    name_prefix            = optional(string)
    name                   = optional(string)
    description            = optional(string)
    region                 = string
    zone                   = optional(string)
    network_name           = optional(string)
    network                = optional(string)
    subnet_name            = optional(string)
    machine_type           = optional(string)
    disk_boot              = optional(bool)
    disk_auto_delete       = optional(bool)
    disk_type              = optional(string)
    disk_size              = optional(number)
    image                  = optional(string)
    os                     = optional(string)
    os_project             = optional(string)
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string))
    network_tags           = optional(list(string))
    labels                 = optional(map(string))
    metadata               = optional(map(string))
    can_ip_forward         = optional(bool)
  }))
  default = []
}

variable "migs" {
  description = "List of Managed Instance Groups"
  type = list(object({
    create                              = optional(bool, true)
    project_id                          = optional(string)
    network_project_id                  = optional(string)
    name_prefix                         = optional(string)
    base_instance_name                  = optional(string)
    region                              = string
    update_instance_redistribution_type = optional(string)
    distribution_policy_target_shape    = optional(string)
    update_type                         = optional(string)
    update_minimal_action               = optional(string)
    update_most_disruptive_action       = optional(string)
    update_replacement_method           = optional(string)
    auto_healing_initial_delay          = optional(number)
    healthchecks = list(object({
      id   = optional(string)
      name = optional(string)
    }))
    autoscaling_mode      = optional(string)
    min_replicas          = optional(number)
    max_replicas          = optional(number)
    cpu_target            = optional(number)
    cpu_predictive_method = optional(string)
    cooldown_period       = optional(number)
  }))
  default = []
}


variable "umigs" {
  description = "List of Unmanaged Instance Groups"
  type = list(object({
    create             = optional(bool, true)
    project_id         = optional(string)
    network_project_id = optional(string)
    name               = optional(string)
    network_name       = optional(string)
    network            = optional(string)
    zone               = string
    instances          = optional(list(string))
    named_ports = optional(list(object({
      name = string
      port = number
    })))
  }))
  default = []
}
