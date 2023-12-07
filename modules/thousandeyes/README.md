# ThousandEyes Enterprise Agent VMs on Google Cloud Platform

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

`var.forwarding_rules` is a list of objects of forwarding rules to be created.  Attributes are described below.

| Name               | Description                                               | Type     | Default   |
|--------------------|-----------------------------------------------------------|----------|-----------|
| create             | Whether or not to create forwarding rule                  | `bool`   | true      |
| network\_name      | Name of the VPC network on the client side                | `string` | "default"  |
| region             | Name of the network this set of firewall rules applies to | `string` | n/a       |
| subnet\_name       | Name of the subnet to create the IP address on            | `string` | "default" |
| subnet\_id         | ID of the subnet to create the IP address on              | `string` | n/a       |
| name               | Explicit name for the PSC IP address and forwarding rule  | `string` | n/a       |
| description        | Description for the IP address                            | `string` | n/a       |
| network\_project\_id | If using Shared VPC, the host project ID for the network  | `string` | n/a       |
| target\_project\_id | Project ID of Published PSC Service                       | `string` | n/a       |
| target\_name       | Name of Published PSC Service                             | `string` | n/a       |
| target\_region     | Region of Published PSC Service                           | `string` | n/a       |

#### Notes

- Either `target_id` or `target_name` must be provided
- If neither `target_id` nor `target_project_id` are provided, target project ID is assumed same as `var.project_id`
- If neither `target_id` nor `target_region` are provided, target region is assumed same as `var.region`
- If `var.region` is not specified, it is assumed to be same as Publisher
- If name is not specified, it will be auto-generated: `psc-endpoint-${REGION}-${SERVICE_NAME}`
- If description is not provided, it will be the target service ID

## Outputs

`forwarding_rules` returns a list of forwarding rules managed by this module.  Attributes are described below.

| Name    | Description                           | Type     |
|---------|---------------------------------------|----------|
| name    | The name of the Forwarding Rule       | `string` |
| address | The IP Address of the Forwarding Rule | `string` |


### Examples

#### Basic Example with custom subnet name and PSC Service ID

```
project_id        = "my-project-id"
network_name      = "my-network-name"
subnet_name       = "my-subnet-name"
region            = "us-east4"
target_id         = "projects/another-project-id/regions/us-east4/serviceAttachments/service-name"
```

#### When local Network uses Shared VPC

```
project_id          = "my-project-id"
network_project_id  = "my-shared-vpc-host-project-id"
network_name        = "my-network-name"
subnet_name         = "my-subnet-name"
region              = "us-west2"
target_id           = "projects/another-project-id/regions/us-west2/serviceAttachments/service-name"
```

#### Auto-Generated Target Service ID

```
project_id        = "my-project-id"
network_name      = "my-network-name"
subnet_name       = "my-subnet-name"
region            = "us-east4"
target_project_id = "my-buddys-project"
target_name       = "my-buddys-service"
target_region     = "us-east4"
```
