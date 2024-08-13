<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, < 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |
| <a name="module_ecs_platform"></a> [ecs\_platform](#module\_ecs\_platform) | terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws | ~> 1.0 |
| <a name="module_virtual_gateway"></a> [virtual\_gateway](#module\_virtual\_gateway) | terraform.registry.launch.nttdata.com/module_primitive/virtual_gateway/aws | ~> 1.0 |
| <a name="module_ecs_appmesh_app"></a> [ecs\_appmesh\_app](#module\_ecs\_appmesh\_app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.priority](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"backend"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "acm": {<br>    "max_length": 60,<br>    "name": "acm"<br>  },<br>  "alb": {<br>    "max_length": 32,<br>    "name": "alb"<br>  },<br>  "alb_sg": {<br>    "max_length": 60,<br>    "name": "albsg"<br>  },<br>  "alb_tg": {<br>    "max_length": 60,<br>    "name": "albtg"<br>  },<br>  "health_check_app_ecs_sg": {<br>    "max_length": 60,<br>    "name": "hcappsg"<br>  },<br>  "health_check_ecs_app": {<br>    "max_length": 60,<br>    "name": "hcsvc"<br>  },<br>  "health_check_ecs_td": {<br>    "max_length": 60,<br>    "name": "hctd"<br>  },<br>  "s3_logs": {<br>    "max_length": 60,<br>    "name": "alblogs"<br>  },<br>  "sds_vg": {<br>    "max_length": 60,<br>    "name": "sdsvg"<br>  },<br>  "task_exec_policy": {<br>    "max_length": 60,<br>    "name": "execplcy"<br>  },<br>  "task_policy": {<br>    "max_length": 60,<br>    "name": "taskplcy"<br>  },<br>  "vgw_ecs_app": {<br>    "max_length": 60,<br>    "name": "vgwsvc"<br>  },<br>  "vgw_ecs_sg": {<br>    "max_length": 60,<br>    "name": "vgwsg"<br>  },<br>  "vgw_ecs_td": {<br>    "max_length": 60,<br>    "name": "vgwtd"<br>  },<br>  "virtual_gateway": {<br>    "max_length": 60,<br>    "name": "vgw"<br>  }<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block related to the VPC | `string` | `"172.55.0.0/16"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | List of private subnet CIDRs | `list(string)` | <pre>[<br>  "172.55.0.0/20",<br>  "172.55.16.0/20",<br>  "172.55.32.0/20"<br>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for the VPC | `list(string)` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS in App Mesh Virtual Gateway and services | `bool` | `false` | no |
| <a name="input_vgw_logs_text_format"></a> [vgw\_logs\_text\_format](#input\_vgw\_logs\_text\_format) | The text format. | `string` | `null` | no |
| <a name="input_vgw_tls_mode"></a> [vgw\_tls\_mode](#input\_vgw\_tls\_mode) | The mode for the listener’s Transport Layer Security (TLS) configuration. Must be one of DISABLED, PERMISSIVE, STRICT. | `string` | `"DISABLED"` | no |
| <a name="input_vgw_health_check_path"></a> [vgw\_health\_check\_path](#input\_vgw\_health\_check\_path) | The destination path for the health check request. | `string` | `"/"` | no |
| <a name="input_vgw_health_check_protocol"></a> [vgw\_health\_check\_protocol](#input\_vgw\_health\_check\_protocol) | The protocol for the health check request. Must be one of [http http2 grpc]. | `string` | `"http"` | no |
| <a name="input_vgw_listener_port"></a> [vgw\_listener\_port](#input\_vgw\_listener\_port) | The port mapping information for the listener. | `number` | `8080` | no |
| <a name="input_vgw_listener_protocol"></a> [vgw\_listener\_protocol](#input\_vgw\_listener\_protocol) | The protocol for the port mapping. Must be one of [http http2 grpc]. | `string` | `"http"` | no |
| <a name="input_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#input\_interface\_vpc\_endpoints) | List of VPC endpoints to be created | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#input\_gateway\_vpc\_endpoints) | List of VPC endpoints to be created | <pre>map(object({<br>    service_name        = string<br>    subnet_names        = optional(list(string), [])<br>    private_dns_enabled = optional(bool, false)<br>    tags                = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_vpce_security_group"></a> [vpce\_security\_group](#input\_vpce\_security\_group) | Default security group to be attached to all VPC endpoints | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_private_ca_arn"></a> [private\_ca\_arn](#input\_private\_ca\_arn) | ARN of the Private CA. This is used to sign private certificates used in App Mesh. Required when TLS is enabled in App Mesh | `string` | n/a | yes |
| <a name="input_app_image_tag"></a> [app\_image\_tag](#input\_app\_image\_tag) | Docker image for the heartBeat application, in the format <docker\_image><docker\_tag> | `string` | n/a | yes |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | The port at which the health check application is running | `number` | n/a | yes |
| <a name="input_app_security_group"></a> [app\_security\_group](#input\_app\_security\_group) | Security group for the health check ECS application. Need to open ports if one wants to access the heart-beat application manually. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be associated with the resources | `map(string)` | `{}` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `false` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service when terraform apply is executed. | `bool` | `false` | no |
| <a name="input_match_path_prefix"></a> [match\_path\_prefix](#input\_match\_path\_prefix) | Gateway route match path prefix. Default is `/`. Conflicts with var.match\_path\_exact and var.match\_path\_regex | `string` | `"/"` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Namespace name of the CloudMap namespace which the Virtual Node references. | `string` | n/a | yes |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | ID of the CloudMap namespace in which SDS to be created. | `string` | n/a | yes |
| <a name="input_app_mesh_id"></a> [app\_mesh\_id](#input\_app\_mesh\_id) | Id/Arn of the App Mesh | `string` | n/a | yes |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS Fargate cluster in which the service is to be deployed | `string` | n/a | yes |
| <a name="input_ignore_changes_task_definition"></a> [ignore\_changes\_task\_definition](#input\_ignore\_changes\_task\_definition) | Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task\_definition is changed outside of terraform | `bool` | `true` | no |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | Lifecycle ignore policy for desired\_count. If true, terraform won't detect changes when desired\_count is changed outside of terraform | `bool` | `true` | no |
| <a name="input_app_task_cpu"></a> [app\_task\_cpu](#input\_app\_task\_cpu) | Amount of CPU to be allocated to the task | `number` | `512` | no |
| <a name="input_app_task_memory"></a> [app\_task\_memory](#input\_app\_task\_memory) | Amount of Memory to be allocated to the task | `number` | `1024` | no |
| <a name="input_app_desired_count"></a> [app\_desired\_count](#input\_app\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_virtual_gateway_name"></a> [virtual\_gateway\_name](#output\_virtual\_gateway\_name) | Name of the Virtual gateway in which gateway route will be created |
| <a name="output_app_mesh_id"></a> [app\_mesh\_id](#output\_app\_mesh\_id) | Id/Arn of the App Mesh |
| <a name="output_app_mesh_name"></a> [app\_mesh\_name](#output\_app\_mesh\_name) | Name of the App Mesh |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
