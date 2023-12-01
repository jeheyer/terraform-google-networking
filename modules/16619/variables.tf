variable "project_id" {
  type = string
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "network_name" {
  type    = string
  default = "default"
}
variable "vpn_name" {
  type    = string
  default = "vpn"
}
variable "router_name" {
  type = string
}
variable "shared_secret" {
  type = string
}
variable "ip_range" {
  type = string
}
variable "peer_ip_address" {
  type = string
}
variable "peer_asn" {
  type = number
}
variable "vpn_gateway" {
  type = string
}
variable "peer_external_gateway" {
  type = string
}