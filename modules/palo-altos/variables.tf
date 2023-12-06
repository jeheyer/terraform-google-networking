variable "project_id" {
  type    = string
  default = null
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "zones" {
  type    = list(string)
  default = ["b", "c"] #
}
variable "subnet_names" {
  type = list(string)
}
variable "machine_type" {
  type    = string
  default = null
  #default = "n1-standard-4"
}
variable "network_tags" {
  type    = list(string)
  default = []
}
variable "vmseries_image" {
  type    = string
  default = null
  #default = "vmseries-bundle1-819"
}
variable "ssh_keys" {
  type    = string
  default = null
}