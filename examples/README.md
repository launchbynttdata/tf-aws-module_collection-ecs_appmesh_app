## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_appmesh_app"></a> [ecs\_appmesh\_app](#module\_ecs\_appmesh\_app) | ../ | n/a |
| <a name="module_ecs_ingress"></a> [ecs\_ingress](#module\_ecs\_ingress) | terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_ingress/aws | n/a |
| <a name="module_ecs_platform"></a> [ecs\_platform](#module\_ecs\_platform) | terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws | ~> 1.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appmesh_mesh.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_mesh) | resource |
| [aws_ecs_cluster.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_vpc.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_sg"></a> [alb\_sg](#input\_alb\_sg) | Security Group for the ALB. https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf | <pre>object({<br/>    description              = optional(string)<br/>    ingress_rules            = optional(list(string))<br/>    ingress_cidr_blocks      = optional(list(string))<br/>    egress_rules             = optional(list(string))<br/>    egress_cidr_blocks       = optional(list(string))<br/>    ingress_with_cidr_blocks = optional(list(map(string)))<br/>    egress_with_cidr_blocks  = optional(list(map(string)))<br/>  })</pre> | n/a | yes |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | The health check path for the application | `string` | n/a | yes |
| <a name="input_app_image_tag"></a> [app\_image\_tag](#input\_app\_image\_tag) | The tag of the application container image. | `string` | n/a | yes |
| <a name="input_app_mesh_id"></a> [app\_mesh\_id](#input\_app\_mesh\_id) | The ID of the AWS App Mesh. | `string` | n/a | yes |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port for the application. | `number` | n/a | yes |
| <a name="input_app_ports"></a> [app\_ports](#input\_app\_ports) | The port(s) at which the application is running, used as listeners in Virtual Node. | `list(number)` | <pre>[<br/>  8080<br/>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use for the subnets. | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | `"us-east-2"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | DNS zone name for the application. | `string` | n/a | yes |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | The ARN of the ECS cluster. | `string` | n/a | yes |
| <a name="input_ecs_security_group"></a> [ecs\_security\_group](#input\_ecs\_security\_group) | Security group for the  ECS application. Must allow the ingress from the virtual gateway on app port | <pre>object({<br/>    ingress_rules            = optional(list(string))<br/>    ingress_cidr_blocks      = optional(list(string))<br/>    ingress_with_cidr_blocks = optional(list(map(string)))<br/>    egress_rules             = optional(list(string))<br/>    egress_cidr_blocks       = optional(list(string))<br/>    egress_with_cidr_blocks  = optional(list(map(string)))<br/>    ingress_with_sg          = optional(list(map(string)))<br/>    egress_with_sg           = optional(list(map(string)))<br/>  })</pre> | `null` | no |
| <a name="input_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#input\_gateway\_vpc\_endpoints) | List of VPC endpoints to be created. AWS currently only supports S3 and DynamoDB gateway interfaces | <pre>map(object({<br/>    service_name        = string<br/>    subnet_names        = optional(list(string), [])<br/>    private_dns_enabled = optional(bool, false)<br/>    route_table_ids     = optional(list(string))<br/>    tags                = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#input\_interface\_vpc\_endpoints) | List of VPC endpoints to be created. Must create endpoints for all AWS services that the ECS services<br/>    needs to communicate over the private network. For example: ECR, CloudWatch, AppMesh etc. In absence of<br/>    NAT gateway, pull images from ECR too needs private endpoint. | <pre>map(object({<br/>    service_name        = string<br/>    subnet_names        = optional(list(string), [])<br/>    private_dns_enabled = optional(bool, false)<br/>    tags                = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | The logical product family name | `string` | `"terratest"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | The logical product service name | `string` | `"ecs_appmesh_app"` | no |
| <a name="input_namespace_description"></a> [namespace\_description](#input\_namespace\_description) | Namespace description | `string` | `""` | no |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | The ID of the service discovery namespace. | `string` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the service discovery namespace. | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet CIDR blocks. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the resources. | `map(string)` | n/a | yes |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of target group configurations for the application. | <pre>list(object({<br/>    name     = string<br/>    port     = number<br/>    protocol = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vgw_listener_port"></a> [vgw\_listener\_port](#input\_vgw\_listener\_port) | Listener port for the virtual gateway. | `number` | n/a | yes |
| <a name="input_vgw_security_group"></a> [vgw\_security\_group](#input\_vgw\_security\_group) | Security group for the Virtual Gateway ECS application. By default, it allows traffic from ALB on the app\_port | <pre>object({<br/>    ingress_rules            = optional(list(string))<br/>    ingress_cidr_blocks      = optional(list(string))<br/>    ingress_with_cidr_blocks = optional(list(map(string)))<br/>    egress_rules             = optional(list(string))<br/>    egress_cidr_blocks       = optional(list(string))<br/>    egress_with_cidr_blocks  = optional(list(map(string)))<br/>  })</pre> | `null` | no |
| <a name="input_virtual_gateway_name"></a> [virtual\_gateway\_name](#input\_virtual\_gateway\_name) | Name of the Virtual gateway in which gateway route will be created | `string` | n/a | yes |
| <a name="input_virtual_node_app_health_check_path"></a> [virtual\_node\_app\_health\_check\_path](#input\_virtual\_node\_app\_health\_check\_path) | The health check path for the virtual node | `string` | `"/health"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_vpce_security_group"></a> [vpce\_security\_group](#input\_vpce\_security\_group) | Default security group to be attached to all VPC endpoints. Must allow relevant ingress and egress traffic. | <pre>object({<br/>    ingress_rules            = optional(list(string))<br/>    ingress_cidr_blocks      = optional(list(string))<br/>    ingress_with_cidr_blocks = optional(list(map(string)))<br/>    egress_rules             = optional(list(string))<br/>    egress_cidr_blocks       = optional(list(string))<br/>    egress_with_cidr_blocks  = optional(list(map(string)))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_mesh_arn"></a> [app\_mesh\_arn](#output\_app\_mesh\_arn) | ARN of the App Mesh |
| <a name="output_app_mesh_id"></a> [app\_mesh\_id](#output\_app\_mesh\_id) | ID of the App Mesh |
| <a name="output_container_json"></a> [container\_json](#output\_container\_json) | Container json for the ECS Task Definition |
| <a name="output_fargate_arn"></a> [fargate\_arn](#output\_fargate\_arn) | The ARN of the ECS fargate cluster |
| <a name="output_namespace_arn"></a> [namespace\_arn](#output\_namespace\_arn) | ARN of the Cloud Map Namespace |
| <a name="output_namespace_hosted_zone"></a> [namespace\_hosted\_zone) | Hosted Zone of Cloud Map Namespace |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | ID of the Cloud Map Namespace |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | Name of the Cloud Map Namespace |
| <a name="output_private_ca_arn"></a> [private\_ca\_arn](#output\_private\_ca\_arn) | ARN of the Private CA |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of private subnets |
| <a name="output_task_definition_name"></a> [task\_definition\_name](#output\_task\_definition\_name) | Task Definition family of the ECS App |
| <a name="output_task_definition_version"></a> [task\_definition\_version](#output\_task\_definition\_version) | Task Definition revision of the ECS App |
| <a name="output_task_exec_role_arn"></a> [task\_exec\_role\_arn](#output\_task\_exec\_role\_arn) | Task role ARN of the ECS App |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | Task Exec role ARN of the ECS App |
| <a name="output_virtual_gateway_arn"></a> [virtual\_gateway\_arn](#output\_virtual\_gateway\_arn) | ARN of the Virtual Gateway |
| <a name="output_virtual_gateway_cert_arn"></a> [virtual\_gateway\_cert\_arn](#output\_virtual\_gateway\_cert\_arn) | ARN of the Virtual Gateway certificate |
| <a name="output_virtual_gateway_name"></a> [virtual\_gateway\_name](#output\_virtual\_gateway\_name) | Name of the Virtual Gateway |
| <a name="output_virtual_gateway_route_arn"></a> [virtual\_gateway\_route_arn](#output\_virtual\_gateway\_route\_arn) | ARN of the Virtual Gateway route for the application |
| <a name="output_virtual_gateway_route_id"></a> [virtual\_gateway\_route\_id](#output\_virtual\_gateway\_route\_id) | ID of the Virtual Gateway route for the application |
| <a name="output_virtual_node_arn"></a> [virtual\_node\_arn](#output\_virtual\_node\_arn) | ARN of the Virtual Node created for the application |
| <a name="output_virtual_node_id"></a> [virtual\_node\_id](#output\_virtual\_node\_id) | ID of the Virtual Node created for the application |
| <a name="output_virtual_router_arn"></a> [virtual\_router\_arn](#output\_virtual\_router\_arn) | ARN of the Virtual Router (if enabled) |
| <a name="output_virtual_router_id"></a> [virtual\_router\_id](#output\_virtual\_router\_id) | ID of the Virtual Router (if enabled) |
| <a name="output_virtual_router_name"></a> [virtual\_router\_name](#output\_virtual\_router\_name) | Name of the Virtual Router (if enabled) |
| <a name="output_virtual_router_route_arn"></a> [virtual\_router\_route_arn](#output\_virtual\_router\_route\_arn) | ARN of the Virtual Router route (if enabled) |
| <a name="output_virtual_router_route_id"></a> [virtual\_router\_route\_id](#output\_virtual\_router\_route\_id) | ID of the Virtual Router route (if enabled) |
| <a name="output_virtual_service_arn"></a> [virtual\_service\_arn](#output\_virtual\_service\_arn) | ARN of the Virtual Service created for the application |
| <a name="output_virtual_service_id"></a> [virtual\_service\_id](#output\_virtual\_service\_id) | ID of the Virtual Service created for the application |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
