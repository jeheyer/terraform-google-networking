# VPNs

Simple HA VPN connections to a set of external routers

## Modules Used

- [hybrid-networking](../modules/hybrid-networking)

---

## Input Variables

| Name                 | Description                                              | Type          | Default         |
|----------------------|----------------------------------------------------------|---------------|-----------------|
| project_id           | Project ID of the GCP project                            | `string`      | n/a             |
| region               | GCP Region Name                                          | `string`      | n/a             |
| cloud_router         | Name of the Cloud Router                                 | `string`      | null            |
| cloud_vpn_gateway    | Name of the Cloud VPN Gateway                            | `string`      | null            |
| network              | name of VPC Network for Cloud Router and VPN Gateway     | `string`      | default         |
| tunnel_range         | IP Range Prefix to use for Tunnel Interfaces             | `string`      | 169.254.2.0/28  |
| peer_bgp_asn         | BGP ASN Number for Peers                         | `number`         | 65000    |
| advertised_ip_ranges | List of IP Ranges to advertise via BGP to Peers                  | `list(string)`   | []       |
| advertised_priority  | BGP Metric value for BGP advertised routes to peers | `number`         | 100      |
| router_set           | Set of Routers to connect to via VPN Tunnels (see below) | `object`      | n/a             |

###

`var.peer_set` is an object.  Attributes are below

| Name                 | Description                                             | Type             | Default  |
|----------------------|---------------------------------------------------------|------------------|----------|
| name                 | Peer (External) VPN Gateway Name                        | `string`         | n/a      |
| description          | Peer (External) VPN Gateway Description                 | `string`         | null     |
| peers              | List of Individual Peers for this Set (see below)                 | `list(object)`   | []       |

#### 

`var.peer_set.peers` is list of objects.  Attributes are below

| Name                 | Description                                                      | Type        | Default  |
|----------------------|------------------------------------------------------------------|-------------|----------|
| name                 | Name of this Peer                                                | `string`    | n/a      |
| ip_address           | Public IP Address of this Peer                                   | `string`    | n/a      |
| shared_secret        | Shared Secret (Pre-shared Key) for this specific peer            | `string`    | null     |
| bgp_asn         | BGP ASN Number for thus specific peer                        | `number`         | null    |
| advertised_priority  | BGP Metric value for BGP advertised routes to this specific peer | `number`    | null     |
| interface_name | Name for Cloud Router Interface | `string` | null | 
| interface_index | Cloud VPN Gateway Interface Index (0 or 1) | `number` | null |

---

## Examples

```terraform
project_id           = "my-project"
network              = "my-network"
region               = "us-west2"
cloud_router         = "my-router"
cloud_vpn_gateway    = "my-vpn-gateway"
tunnel_range         = "169.254.22.48/28"
peer_bgp_asn         = 65123
advertised_ip_ranges = ["10.20.160.0/19"]
peer_set = {
  name                 = "my-routers"
  description          = "Cisco ISR 4k pair in My Data Center"
  peers = [
    {
      name                 = "router-01"
      ip_address           = "203.0.113.11"
      advertised_priority  = 101
    },
    {
      name                 = "router-02"
      ip_address           = "203.0.113.12"
      advertised_priority  = 102
    },
  ]
}
```

## Outputs

`vpn_tunnels` - Information about the VPN Tunnels
