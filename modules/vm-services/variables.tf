variable "project_id" {
  type = string
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "host_project_id" {
  type    = string
  default = null
}
variable "network" {
  type    = string
  default = "default"
}
variable "machine_type" {
  type    = string
  default = "e2-micro"
}
variable "image" {
  type    = string
  default = "debian-cloud/debian-11"
}
variable "network_tags" {
  type    = list(string)
  default = []
}
variable "startup_script" {
  type    = string
  default = null
}
variable "deployments" {
  type = list(object({
    name            = optional(string)
    region          = optional(string)
    zone            = optional(string)
    network         = optional(string)
    network_tags    = optional(list(string))
    subnet          = optional(string)
    host_project_id = optional(string)
    machine_type    = optional(string)
    image           = optional(string)
    startup_script  = optional(string)
  }))
  default = []
}

