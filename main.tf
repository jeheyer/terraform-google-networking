# VPC Networks, subnets, cloud routers, cloud nats, etc
module "vpc-networks" {
  source       = "git::https://github.com/jeheyer/terraform-google-networking//modules/vpc-networks"
  project_id   = var.project_id
  region       = var.region
  vpc_networks = var.vpc_networks
  defaults     = var.defaults
}

# DNS Zones and Policies
module "dns" {
  source       = "git::https://github.com/jeheyer/terraform-google-networking//modules/dns"
  project_id   = var.project_id
  dns_zones    = var.dns_zones
  dns_policies = var.dns_policies
  depends_on   = [module.vpc-networks]
}

# Instances, Instance Groups, and Instance Templates
module "instances" {
  source     = "git::https://github.com/jeheyer/terraform-google-networking//modules/instances"
  project_id = var.project_id
  instances  = var.instances
  depends_on = [module.vpc-networks]
}
