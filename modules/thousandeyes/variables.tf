variable "project_id" {
  type = string
}
variable "name_prefix" {
  type    = string
  default = "thousandeyes"
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "network_name" {
  type    = string
  default = "default"
}
variable "machine_type" {
  type    = string
  default = "e2-small"
}
variable "image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "network_tags" {
  type    = list(string)
  default = ["thousandeyes"]
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

