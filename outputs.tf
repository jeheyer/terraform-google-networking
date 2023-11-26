output "vpc-networks" { value = module.vpc-networks.vpc_networks }
output "dns_zones" { value = module.dns.dns_zones }
output "dns_policies" { value = module.dns.dns_policies }
output "instances" { value = module.instances.instances }
