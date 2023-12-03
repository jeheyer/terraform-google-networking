
output "firewall_rules" {
  value = [for i, v in local.firewall_rules :
    {
      name      = v.name
      priority  = v.priority
      direction = v.direction
    }
  ]
}
