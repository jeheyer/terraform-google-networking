# ThousandEyes Enterprise Agent VMs on Google Cloud Platform

---

# Resources

- [google_compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

---

# Inputs
 

| Name                | Description                              | Type           | Default                           |
|---------------------|------------------------------------------|----------------|-----------------------------------|
| project\_id         | GCP Project ID for the VMs               | `string`       | n/a                               |
| host_projec\_id     | If using Shared VPC, the Host Project ID | `string`       | null                              |
| name_prefix         | Naming Prefix for instances              | `string`       | "thousandeyes"                    |
| network_name        | VPC Network Name                         | `string`       | "default"                         |
| machine_type        | Machine Type for the VMs                 | `string`       | "e2-small"                        | 
| network_tags        | Network Tags for the VMs                 | `list(string)` | ["thousandeyes"]                  |
| image               | Install Image for the VMs                | `string`       | "ubuntu-os-cloud/ubuntu-2004-lts" |
| account_group_token | Account Token to use                     | `string`       | n/a                               | 
| deployments         | List of deployments with this configuration | `list(object)` | n/a |

Attributes for the `deployments` list of objects is described below

| Name         | Description                       | Type        | Default  |
|--------------|-----------------------------------|-------------|----------|
| name         | Explicit name for the VM          | `string`    | n/a      |
| machine_type | Machine Type for this specific VM | `string`    | n/a      |
| region       | GCP Region for the VM             | `string`    | n/a      |
| zone         | GCP Zone for the VM               | `string`    | n/a      |
| subnet_name  | Name of the Subnetwork            | `string`    | "default" |

## Notes:

- Region or zone must be specified.
- If name is not given, it will be auto-generated with `var.name_prefix` and the region name.

---

##2 Examples

```
project_id        = "my-project-id"
network_name      = "my-network-name"
```

