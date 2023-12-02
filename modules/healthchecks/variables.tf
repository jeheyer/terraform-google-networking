variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden at resource level)"
  default     = null
}
variable "healthchecks" {
  type = list(object({
    create              = optional(bool, true)
    project_id          = optional(string)
    name                = optional(string)
    description         = optional(string)
    region              = optional(string)
    port                = optional(number)
    protocol            = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    request_path        = optional(string)
    response            = optional(string)
    host                = optional(string)
    legacy              = optional(bool)
    logging             = optional(bool)
    proxy_header        = optional(string)
  }))
  default = []
}

