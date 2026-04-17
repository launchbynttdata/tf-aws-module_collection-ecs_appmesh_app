# Complete example with TLS enabled

This example provisions the App Mesh application along with the VPC, App Mesh platform, and ingress dependencies needed to run it.

## Known Issues

1. The supporting modules may need a staged apply in some environments because the ingress and application depend on certificates, DNS, and App Mesh resources created earlier in the graph.
2. Make sure the app image is reachable from the VPC. The example uses VPC endpoints and a public image for simplicity.
3. The Route53 hosted zone and Private CA inputs in `test.tfvars` assume sandbox test infrastructure already exists.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |
| <a name="module_ecs_platform"></a> [ecs\_platform](#module\_ecs\_platform) | terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws | ~> 1.0 |
| <a name="module_ecs_ingress"></a> [ecs\_ingress](#module\_ecs\_ingress) | terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_ingress/aws | ~> 1.0 |
| <a name="module_ecs_appmesh_app"></a> [ecs\_appmesh\_app](#module\_ecs\_appmesh\_app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.priority](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Name of the product family for which the resource is created. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Name of the product service for which the resource is created. | `string` | `"appmeshapp"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment where resource is going to be deployed. | `string` | `"sandbox"` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned. | `string` | `"us-east-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block related to the VPC. | `string` | `"10.1.0.0/16"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet cidrs. | `list(string)` | <pre>[<br>  "10.1.1.0/24",<br>  "10.1.2.0/24",<br>  "10.1.3.0/24"<br>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for the VPC. | `list(string)` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#input\_interface\_vpc\_endpoints) | List of VPC interface endpoints to be created. | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#input\_gateway\_vpc\_endpoints) | List of VPC gateway endpoints to be created. | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_vpce_security_group"></a> [vpce\_security\_group](#input\_vpce\_security\_group) | Default security group to be attached to all VPC endpoints. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_private_ca_arn"></a> [private\_ca\_arn](#input\_private\_ca\_arn) | ARN of the Private CA used to sign private certificates used in App Mesh. | `string` | n/a | yes |
| <a name="input_alb_sg"></a> [alb\_sg](#input\_alb\_sg) | Security Group for the ALB. | <pre>object({<br>    description              = optional(string)<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Name of the Route53 DNS Zone where custom DNS records will be created. | `string` | n/a | yes |
| <a name="input_private_zone"></a> [private\_zone](#input\_private\_zone) | Whether the dns\_zone\_name provided above is a private or public hosted zone. | `bool` | n/a | yes |
| <a name="input_vgw_security_group"></a> [vgw\_security\_group](#input\_vgw\_security\_group) | Security group for the Virtual Gateway ECS application. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_ingress_app_port"></a> [ingress\_app\_port](#input\_ingress\_app\_port) | Port used by the ingress heartbeat application. | `number` | `8080` | no |
| <a name="input_ingress_app_image_tag"></a> [ingress\_app\_image\_tag](#input\_ingress\_app\_image\_tag) | Docker image for the ingress heartbeat application. | `string` | n/a | yes |
| <a name="input_ingress_app_security_group"></a> [ingress\_app\_security\_group](#input\_ingress\_app\_security\_group) | Security group for the ingress heartbeat application. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_app_ports"></a> [app\_ports](#input\_app\_ports) | Ports at which the application is running. | `list(number)` | n/a | yes |
| <a name="input_app_image_tag"></a> [app\_image\_tag](#input\_app\_image\_tag) | Docker image of the application in the format <docker\_image>:<tag>. | `string` | n/a | yes |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | Path of the health endpoint inside the app container. | `string` | `""` | no |
| <a name="input_virtual_node_app_health_check_path"></a> [virtual\_node\_app\_health\_check\_path](#input\_virtual\_node\_app\_health\_check\_path) | Path in the app for Virtual Node to perform health check. | `string` | `"/"` | no |
| <a name="input_ecs_security_group"></a> [ecs\_security\_group](#input\_ecs\_security\_group) | Security group for the ECS application. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>    ingress_with_sg          = optional(list(map(string)))<br>    egress_with_sg           = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment when terraform apply is executed. | `bool` | `true` | no |
| <a name="input_redeploy_on_apply"></a> [redeploy\_on\_apply](#input\_redeploy\_on\_apply) | Redeploy the service every time terraform apply is executed. | `bool` | `true` | no |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | Lifecycle ignore policy for desired\_count. | `bool` | `false` | no |
| <a name="input_ignore_changes_task_definition"></a> [ignore\_changes\_task\_definition](#input\_ignore\_changes\_task\_definition) | Lifecycle ignore policy for task\_definition. | `bool` | `false` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Whether to wait for ECS service steady state. | `bool` | `false` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired ECS service count. | `number` | `1` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Health check grace period for the ingress ECS service. | `number` | `120` | no |
| <a name="input_match_path_prefix"></a> [match\_path\_prefix](#input\_match\_path\_prefix) | Path prefix to match in the ingress URL for this app. | `string` | `"/app"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be associated with the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_mesh_id"></a> [app\_mesh\_id](#output\_app\_mesh\_id) | n/a |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | n/a |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | n/a |
| <a name="output_private_ca_arn"></a> [private\_ca\_arn](#output\_private\_ca\_arn) | n/a |
| <a name="output_virtual_gateway_name"></a> [virtual\_gateway\_name](#output\_virtual\_gateway\_name) | n/a |
| <a name="output_virtual_node_id"></a> [virtual\_node\_id](#output\_virtual\_node\_id) | n/a |
| <a name="output_virtual_service_id"></a> [virtual\_service\_id](#output\_virtual\_service\_id) | n/a |
| <a name="output_virtual_router_id"></a> [virtual\_router\_id](#output\_virtual\_router\_id) | n/a |
| <a name="output_virtual_gateway_route_id"></a> [virtual\_gateway\_route\_id](#output\_virtual\_gateway\_route\_id) | n/a |
| <a name="output_ecs_sg_id"></a> [ecs\_sg\_id](#output\_ecs\_sg\_id) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
