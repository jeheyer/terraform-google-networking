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
variable "vpc_networks" {
  type = list(object({
    create                  = optional(bool, true)
    project_id              = optional(string)
    name                    = string
    description             = optional(string)
    mtu                     = optional(number, 1460)
    enable_global_routing   = optional(bool, false)
    auto_create_subnetworks = optional(bool, false)
    attached_projects       = optional(list(string))
    shared_accounts         = optional(list(string))
    subnets = optional(list(object({
      create                   = optional(bool, true)
      project_id               = optional(string)
      name                     = optional(string, "default")
      description              = optional(string)
      region                   = optional(string)
      stack_type               = optional(string)
      ip_range                 = string
      purpose                  = optional(string)
      role                     = optional(string)
      private_access           = optional(bool, true)
      flow_logs                = optional(bool)
      log_aggregation_interval = optional(string)
      log_sampling_rate        = optional(number)
      attached_projects        = optional(list(string))
      shared_accounts          = optional(list(string))
      secondary_ranges = optional(list(object({
        name  = optional(string)
        range = string
      })))
    })))
    routes = optional(list(object({
      create        = optional(bool, true)
      project_id    = optional(string)
      name          = optional(string)
      description   = optional(string)
      dest_range    = optional(string)
      dest_ranges   = optional(list(string))
      priority      = optional(number)
      instance_tags = optional(list(string))
      next_hop      = optional(string)
      next_hop_zone = optional(string)
    })))
    peerings = optional(list(object({
      create                              = optional(bool, true)
      project_id                          = optional(string)
      name                                = optional(string)
      peer_project_id                     = optional(string)
      peer_network_name                   = optional(string)
      peer_network_link                   = optional(string)
      import_custom_routes                = optional(bool)
      export_custom_routes                = optional(bool)
      import_subnet_routes_with_public_ip = optional(bool)
      export_subnet_routes_with_public_ip = optional(bool)
    })))
    ip_ranges = optional(list(object({
      create      = optional(bool, true)
      project_id  = optional(string)
      name        = optional(string)
      description = optional(string)
      ip_range    = string
    })))
    service_connections = optional(list(object({
      create               = optional(bool, true)
      project_id           = optional(string)
      name                 = optional(string)
      service              = optional(string)
      ip_ranges            = list(string)
      import_custom_routes = optional(bool)
      export_custom_routes = optional(bool)
    })))
    cloud_routers = optional(list(object({
      create                 = optional(bool, true)
      project_id             = optional(string)
      name                   = optional(string)
      description            = optional(string)
      region                 = string
      bgp_asn                = optional(number)
      bgp_keepalive_interval = optional(number)
      advertised_groups      = optional(list(string))
      advertised_ip_ranges = optional(list(object({
        create      = optional(bool)
        range       = string
        description = optional(string)
      })))
    })))
    cloud_nats = optional(list(object({
      create            = optional(bool, true)
      project_id        = optional(string)
      name              = optional(string)
      region            = optional(string)
      cloud_router      = optional(string)
      cloud_router_name = optional(string)
      subnets           = optional(list(string))
      num_static_ips    = optional(number)
      static_ips = optional(list(object({
        name        = optional(string)
        description = optional(string)
        address     = optional(string)
      })))
      log_type                     = optional(string)
      enable_dpa                   = optional(bool)
      min_ports_per_vm             = optional(number)
      max_ports_per_vm             = optional(number)
      enable_eim                   = optional(bool)
      udp_idle_timeout             = optional(number)
      tcp_established_idle_timeout = optional(number)
      tcp_time_wait_timeout        = optional(number)
      tcp_transitory_idle_timeout  = optional(number)
      icmp_idle_timeout            = optional(number)
    })))
  }))
  default = []
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
    domain_names          = optional(list(string))
    consumer_reject_lists = optional(list(string))
    reconcile_connections = optional(bool)
  }))
  default = []
}
