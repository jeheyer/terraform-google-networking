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
variable "network_name" {
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
variable "account_group_token" {
  type = string
}
variable "deployments" {
  type = list(object({
    name         = optional(string)
    region       = optional(string)
    zone         = optional(string)
    subnet_name  = optional(string)
    machine_type = optional(string)
  }))
  default = []
}

