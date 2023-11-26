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
variable "vpc_networks" {
  type = list(object({
    create                  = optional(bool, true)
    project_id              = optional(string)
    name                    = string
    description             = optional(string)
    mtu                     = optional(number)
    enable_global_routing   = optional(bool)
    auto_create_subnetworks = optional(bool)
    attached_projects       = optional(list(string))
    shared_accounts         = optional(list(string))
    subnets = optional(list(object({
      create                   = optional(bool, true)
      project_id               = optional(string)
      name                     = optional(string)
      description              = optional(string)
      region                   = optional(string)
      stack_type               = optional(string)
      ip_range                 = string
      purpose                  = optional(string)
      role                     = optional(string)
      private_access           = optional(bool)
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
    vpc_access_connectors = optional(list(object({
      create             = optional(bool, true)
      project_id         = optional(string)
      network_project_id = optional(string)
      name               = optional(string)
      region             = optional(string)
      cidr_range         = optional(string)
      subnet_name        = optional(string)
      vpc_network_name   = optional(string)
      min_throughput     = optional(number)
      max_throughput     = optional(number)
      min_instances      = optional(number)
      max_instances      = optional(number)
      machine_type       = optional(string)
    })))
  }))
  default = []
}


variable "defaults" {
  type = object({
    cloud_router_bgp_asn                   = optional(number)
    cloud_router_bgp_keepalive_interval    = optional(number)
    subnet_stack_type                      = optional(string)
    subnet_private_access                  = optional(bool)
    subnet_flow_logs                       = optional(bool)
    subnet_log_aggregation_interval        = optional(string)
    subnet_log_sampling_rate               = optional(string)
    cloud_nat_enable_dpa                   = optional(bool)
    cloud_nat_enable_eim                   = optional(bool)
    cloud_nat_udp_idle_timeout             = optional(number)
    cloud_nat_tcp_established_idle_timeout = optional(number)
    cloud_nat_tcp_time_wait_timeout        = optional(number)
    cloud_nat_tcp_transitory_idle_timeout  = optional(number)
    cloud_nat_icmp_idle_timeout            = optional(number)
    cloud_nat_min_ports_per_vm             = optional(number)
    cloud_nat_max_ports_per_vm             = optional(number)
    cloud_nat_log_type                     = optional(string)
  })
  default = {}
}
