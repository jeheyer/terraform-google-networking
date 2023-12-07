output "instances" {
  value = { for i, v in module.instances.instances :
    v.index_key => {
      name        = v.name
      zone        = v.zone
      internal_ip = v.internal_ip
      external_ip = v.external_ip
    }
  }
}
