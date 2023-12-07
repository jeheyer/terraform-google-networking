# Simple horizontal-scaling of single VM deployments.  

Ideal for:

- Bastion hosts
- Monitoring agents
- Management VMs

## Applicable Child Modules 

- [instances](modules/instances/)

---

# Inputs
 
`var.project_id` is required.  All other variables are optional.  

| Name            | Description                                 | Type           | Default                  |
|-----------------|---------------------------------------------|----------------|--------------------------|
| project_id      | GCP Project ID for the VMs                  | `string`       | n/a                      |
| host_project_id | If using Shared VPC, the Host Project ID    | `string`       | null                     |
| name_prefix     | Naming Prefix for instances                 | `string`       | "instance"               |
| network         | VPC Network Name                            | `string`       | "default"                |
| machine_type    | Machine Type for the VMs                    | `string`       | "e2-small"               | 
| network_tags    | Network Tags for the VMs                    | `list(string)` | []                       |
| image           | Install Image for the VMs                   | `string`       | "debian-cloud/debian-11" |
| startup_script  | Startup Script                              | `string`       | null                     | 
| deployments     | List of deployments with this configuration | `list(object)` | []                       |

Attributes for the `deployments` list of objects is described below

| Name           | Description                         | Type           | Default      |
|----------------|-------------------------------------|----------------|--------------|
| name           | Explicit name for this VM           | `string`       | n/a          |
| machine_type   | Machine Type for this VM            | `string`       | n/a          |
| region         | GCP Region for this VM              | `string`       | n/a          |
| zone           | GCP Zone for this VM                | `string`       | n/a          |
| subnet         | Name of the Subnetwork for this VM  | `string`       | "default"    |
| network        | VPC Network Name                    | `string`       | "default"    |
| machine_type   | Machine Type for the VMs            | `string`       | n/a          | 
| network_tags   | Network Tags for the VMs            | `list(string)` | n/a          |
| image          | Install Image for the VMs           | `string`       | n/a          |

## Notes:

- `region` or `zone` must be specified.
- If name is not given, it will be auto-generated with `var.name_prefix` and the region name.

---

# Examples

```
project_id        = "my-project-id"
network           = "my-network-name"
name_prefix       = "service1"
machine_type      = "g1-small"
deployments = [
  {
    name   = "east"
    region = "us-east1"
  },
  {
    name   = "west"
    region = "us-west1"
  },
]
```

