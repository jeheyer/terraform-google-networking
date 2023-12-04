variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "backends" {
  description = "List of LB Backend Services & Buckets"
  type = list(object({
    create             = optional(bool, true)
    project_id         = optional(string)
    name               = optional(string)
    type               = optional(string) # We'll try and figure it out automatically
    description        = optional(string)
    region             = optional(string)
    bucket_name        = optional(string)
    psc_target         = optional(string)
    port               = optional(number)
    port_name          = optional(string)
    protocol           = optional(string)
    enable_cdn         = optional(bool)
    cdn_cache_mode     = optional(string)
    timeout            = optional(number)
    logging            = optional(bool)
    logging_rate       = optional(number)
    affinity_type      = optional(string)
    locality_lb_policy = optional(string)
    cloudarmor_policy  = optional(string)
    healthcheck        = optional(string)
    healthchecks       = optional(list(string))
    group              = optional(string)
    groups             = optional(list(string)) # List of Instance Group or NEG IDs
    rnegs = optional(list(object({
      region                = optional(string)
      psc_target            = optional(string)
      network_name          = optional(string)
      subnet_name           = optional(string)
      cloud_run_name        = optional(string) # Cloud run service name
      app_engine_name       = optional(string) # App Engine service name
      container_image       = optional(string) # Default to GCR if not full URL
      docker_image          = optional(string) # Pull image from docker.io
      container_port        = optional(number) # Cloud run container port
      allow_unauthenticated = optional(bool)
      allowed_members       = optional(list(string))
    })))
    ineg = optional(object({
      fqdn       = optional(string)
      ip_address = optional(string)
      port       = optional(number)
    }))
    iap = optional(object({
      application_title = optional(string)
      support_email     = optional(string)
      members           = optional(list(string))
    }))
    capacity_scaler             = optional(number)
    max_utilization             = optional(number)
    max_rate_per_instance       = optional(number)
    max_connections             = optional(number)
    connection_draining_timeout = optional(number)
    custom_request_headers      = optional(list(string))
    custom_response_headers     = optional(list(string))
  }))
  default = [{
    name = "example"
    ineg = { fqdn = "teapotme.com" }
  }]
}
