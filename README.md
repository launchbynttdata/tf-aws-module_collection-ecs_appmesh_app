# tf-aws-module_collection-ecs_appmesh_app

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This terraform module creates a ECS App (ecs service) with App Mesh enabled. The following resources are created
- Virtual Node
- Virtual Service
- ECS Task Definition
- ECS Service
- Task Role and Task Exec role for ECS Task
- Security Group for ECS Service
- Private Cert for TLS in Virtual Node
- Virtual Gateway route (optional if ingress is needed)
- Service Discovery Service

Added support for a mitmproxy (encoder) in the task. The traffic now will follow this route :
```shell
   client -> nginx -> mitm-proxy(decoder)-> Virtual Gateway -> App Envoy -> mitm-proxy(encoder) -> app
```
This was added to fix the issue that `envoy` introduces. The AWS provided envoy proxy image by default uses `http2` which normalizes (converts to lower case) all the response headers.
In order to make this service compatible with other http1 compliant applications, the mitm-proxy (encoder) encodes the response headers before it travels through envoy.
The mitm-proxy(decoder) then searches for any encoded headers and upon finding any, decodes and attaches them to the response
before sending it to the client.

### Dependencies
This module is dependent on `ecs_appmesh_platform` and `ecs_appmesh_ingress` modules. Those modules must be provisioned beforehand for this module to be provisioned

## Usage
A sample variable file `example.tfvars` is available in the root directory which can be used to test this module. User needs to follow the below steps to execute this module
1. Update the `example.tfvars` to manually enter values for all fields marked within `<>` to make the variable file usable
2. Create a file `provider.tf` with the below contents
   ```
    provider "aws" {
      profile = "<profile_name>"
      region  = "<region_name>"
    }
    ```
   If using `SSO`, make sure you are logged in `aws sso login --profile <profile_name>`
3. Make sure terraform binary is installed on your local. Use command `type terraform` to find the installation location. If you are using `asdf`, you can run `asfd install` and it will install the correct terraform version for you. `.tool-version` contains all the dependencies.
4. Run the `terraform` to provision infrastructure on AWS
    ```
    # Initialize
    terraform init
    # Plan
    terraform plan -var-file example.tfvars
    # Apply (this is create the actual infrastructure)
    terraform apply -var-file example.tfvars -auto-approve
   ```

## Known Issues
1. We cannot enable the flag `redeploy_on_apply=true`. An open provider issue is blocking that - https://github.com/hashicorp/terraform-provider-aws/issues/28070. Terraform will only deploy the service the very first time. For all subsequent deployments, we will use AWS CLI. The task definition and the service `desired_count` are added to lifecycle `ignore_changes` list. So, terraform won't detect changes made outside of terraform.
2. Doesn't currently support creating `gateway routes` for multiple ports open in ECS Task. Gateway route will be created for the first port only.
3. If the application port (var.app_ports) changes, then we need to destroy the module and recreate again. As we get an error while updating the virtual node listener that an existing gateway route is using the listener.
   ```shell
      Error: updating App Mesh Virtual Node (c3599c26-dbee-41d6-81ca-21018ff9bba4): BadRequestException: 1 Virtual Node listener(s) cannot be removed because they are targeted by existing Gateway Routes through Virtual Service provider. Listing up to 5 PortMappings: [(Port: 8080, Protocol: HTTP)]
   ```

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `aws_env.sh` file on local workstation. Developer would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `aws` specific. If primitive/segment under development uses any other cloud provider than AWS, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "aws" {
  profile = "<profile_name>"
  region  = "<region_name>"
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests

# Know Issues
Currently, the `encrypt at transit` is not supported in terraform. There is an open issue for this logged with Hashicorp - https://github.com/hashicorp/terraform-provider-aws/pull/26987

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, < 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_sds"></a> [sds](#module\_sds) | terraform.registry.launch.nttdata.com/module_primitive/service_discovery_service/aws | ~> 1.0.0 |
| <a name="module_private_cert"></a> [private\_cert](#module\_private\_cert) | terraform.registry.launch.nttdata.com/module_primitive/acm_private_cert/aws | ~> 1.0.0 |
| <a name="module_virtual_router"></a> [virtual\_router](#module\_virtual\_router) | terraform.registry.launch.nttdata.com/module_primitive/virtual_router/aws | ~> 1.0.0 |
| <a name="module_virtual_route"></a> [virtual\_route](#module\_virtual\_route) | terraform.registry.launch.nttdata.com/module_primitive/appmesh_route/aws | ~> 1.0.0 |
| <a name="module_virtual_node"></a> [virtual\_node](#module\_virtual\_node) | terraform.registry.launch.nttdata.com/module_primitive/virtual_node/aws | ~> 1.0.0 |
| <a name="module_virtual_service"></a> [virtual\_service](#module\_virtual\_service) | terraform.registry.launch.nttdata.com/module_primitive/virtual_service/aws | ~> 1.0.0 |
| <a name="module_gateway_route"></a> [gateway\_route](#module\_gateway\_route) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-appmesh_gateway_route.git | 1.0.1 |
| <a name="module_ecs_task_execution_policy"></a> [ecs\_task\_execution\_policy](#module\_ecs\_task\_execution\_policy) | cloudposse/iam-policy/aws | ~> 0.4.0 |
| <a name="module_ecs_task_policy"></a> [ecs\_task\_policy](#module\_ecs\_task\_policy) | cloudposse/iam-policy/aws | ~> 0.4.0 |
| <a name="module_container_definitions"></a> [container\_definitions](#module\_container\_definitions) | git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git | tags/0.59.0 |
| <a name="module_sg_ecs_service"></a> [sg\_ecs\_service](#module\_sg\_ecs\_service) | terraform-aws-modules/security-group/aws | ~> 4.17.1 |
| <a name="module_app_ecs_service"></a> [app\_ecs\_service](#module\_app\_ecs\_service) | cloudposse/ecs-alb-service-task/aws | ~> 0.69.0 |
| <a name="module_autoscaling_target"></a> [autoscaling\_target](#module\_autoscaling\_target) | terraform.registry.launch.nttdata.com/module_primitive/autoscaling_target/aws | ~> 1.0.0 |
| <a name="module_autoscaling_policies"></a> [autoscaling\_policies](#module\_autoscaling\_policies) | terraform.registry.launch.nttdata.com/module_primitive/autoscaling_policy/aws | ~> 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"backend"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br>    {<br>      name       = string<br>      max_length = optional(number, 60)<br>    }<br>  ))</pre> | <pre>{<br>  "acm": {<br>    "max_length": 60,<br>    "name": "acm"<br>  },<br>  "app_ecs_sg": {<br>    "max_length": 60,<br>    "name": "appsg"<br>  },<br>  "ecs_app": {<br>    "max_length": 60,<br>    "name": "svc"<br>  },<br>  "ecs_td": {<br>    "max_length": 60,<br>    "name": "td"<br>  },<br>  "gateway_route": {<br>    "max_length": 60,<br>    "name": "gwroute"<br>  },<br>  "router_route": {<br>    "max_length": 60,<br>    "name": "vroute"<br>  },<br>  "service_discovery_service": {<br>    "max_length": 60,<br>    "name": "vsvc"<br>  },<br>  "task_exec_policy": {<br>    "max_length": 60,<br>    "name": "execplcy"<br>  },<br>  "task_exec_role": {<br>    "max_length": 60,<br>    "name": "execrole"<br>  },<br>  "task_policy": {<br>    "max_length": 60,<br>    "name": "taskplcy"<br>  },<br>  "task_role": {<br>    "max_length": 60,<br>    "name": "taskrole"<br>  },<br>  "virtual_node": {<br>    "max_length": 60,<br>    "name": "vnode"<br>  },<br>  "virtual_router": {<br>    "max_length": 60,<br>    "name": "vrouter"<br>  },<br>  "virtual_service": {<br>    "max_length": 60,<br>    "name": "vsvc"<br>  }<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID of the VPC where infrastructure will be provisioned | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Namespace name of the CloudMap namespace which the Virtual Node references. | `string` | n/a | yes |
| <a name="input_namespace_id"></a> [namespace\_id](#input\_namespace\_id) | ID of the CloudMap namespace in which SDS to be created. | `string` | n/a | yes |
| <a name="input_app_mesh_id"></a> [app\_mesh\_id](#input\_app\_mesh\_id) | Id/Name of the App Mesh | `string` | n/a | yes |
| <a name="input_virtual_gateway_name"></a> [virtual\_gateway\_name](#input\_virtual\_gateway\_name) | Name of the Virtual gateway in which gateway route will be created | `string` | n/a | yes |
| <a name="input_private_ca_arn"></a> [private\_ca\_arn](#input\_private\_ca\_arn) | ARN of the Private CA. This is used to sign private certificates used in App Mesh. Required when TLS is enabled in App Mesh | `string` | `""` | no |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS in App Mesh Virtual Service/Node | `bool` | `true` | no |
| <a name="input_enable_virtual_router"></a> [enable\_virtual\_router](#input\_enable\_virtual\_router) | Whether to create a Virtual Router and route traffic to virtual Node via it | `bool` | `true` | no |
| <a name="input_router_retry_policy"></a> [router\_retry\_policy](#input\_router\_retry\_policy) | Rules for retry policies to be applied to this route | <pre>object({<br>    http_retry_events = list(string)<br>    max_retries       = number<br>    per_entry_timeout = object({<br>      unit  = string<br>      value = number<br>    })<br>    tcp_retry_events = list(string)<br>  })</pre> | `null` | no |
| <a name="input_app_ports"></a> [app\_ports](#input\_app\_ports) | The port(s) at which the application is running. These ports will be accessed by the mitm-proxy to forward traffic. | `list(number)` | `[]` | no |
| <a name="input_mitm_proxy_ports"></a> [mitm\_proxy\_ports](#input\_mitm\_proxy\_ports) | The port(s) at which the mitm\_proxy (encoder) is running. The same ports are used as listeners in Virtual Node | `list(number)` | `[]` | no |
| <a name="input_virtual_node_app_health_check_path"></a> [virtual\_node\_app\_health\_check\_path](#input\_virtual\_node\_app\_health\_check\_path) | Path in the app for Virtual Node to perform health check.<br>    If empty, then no health check is configured on the Virtual Node<br>    Note: Virtual node just logs the health check output to envoy proxy logs, but doesn't evict<br>    the unhealthy containers. | `string` | `"/"` | no |
| <a name="input_idle_duration"></a> [idle\_duration](#input\_idle\_duration) | Idle duration for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |
| <a name="input_per_request_timeout"></a> [per\_request\_timeout](#input\_per\_request\_timeout) | Per Request timeout for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |
| <a name="input_print_container_json"></a> [print\_container\_json](#input\_print\_container\_json) | Print the container JSON object as output. Useful for debugging | `bool` | `false` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS Fargate cluster in which the service is to be deployed | `string` | n/a | yes |
| <a name="input_app_image_tag"></a> [app\_image\_tag](#input\_app\_image\_tag) | The docker image of the application in the format <docker\_image>:<tag> | `string` | n/a | yes |
| <a name="input_app_environment"></a> [app\_environment](#input\_app\_environment) | Environment variables to be injected into the application containers | `map(string)` | `{}` | no |
| <a name="input_app_secrets"></a> [app\_secrets](#input\_app\_secrets) | Secrets to be injected into the application containers. Map of secret Manager ARNs | `map(string)` | `{}` | no |
| <a name="input_mitm_proxy_image_tag"></a> [mitm\_proxy\_image\_tag](#input\_mitm\_proxy\_image\_tag) | The docker image of the mitm-proxy in the format <docker\_image>:<tag> | `string` | `""` | no |
| <a name="input_mitm_proxy_environment"></a> [mitm\_proxy\_environment](#input\_mitm\_proxy\_environment) | Environment variables to be injected into the mitm-proxy encoder container | `map(string)` | `{}` | no |
| <a name="input_mitm_proxy_secrets"></a> [mitm\_proxy\_secrets](#input\_mitm\_proxy\_secrets) | Secrets to be injected into the mitm-proxy encoder container. Map of secret Manager ARNs | `map(string)` | `{}` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Flag to determine if auto scaling is enabled for the application | `bool` | `false` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Min capacity of the scalable target. | `number` | `1` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Max capacity of the scalable target. | `number` | `4` | no |
| <a name="input_autoscaling_policies"></a> [autoscaling\_policies](#input\_autoscaling\_policies) | A map of autoscaling policies to be created for this ECS Service<br>    The `predefined_metric_type` must be ECSServiceAverageCPUUtilization or ECSServiceAverageMemoryUtilization<br>    `target_value` is the threshold for the metric at which the auto-scaling will be triggerred.<br>    `scale_in_cooldown` and `scale_out_cooldown` respectively are amount of time, in seconds, after a scale in activity<br>      completes before another scale in activity can start. | <pre>map(object({<br>    predefined_metric_type = string<br>    target_value           = string<br>    scale_in_cooldown      = optional(string, 60)<br>    scale_out_cooldown     = optional(string, 60)<br>  }))</pre> | `{}` | no |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | A path of the health endpoint inside the container for Container level health check. Example. `/health`.<br>    The complete health check would be http://localhost:<container\_port>/health<br>    By default is no health check configured | `string` | `""` | no |
| <a name="input_app_health_check_options"></a> [app\_health\_check\_options](#input\_app\_health\_check\_options) | Health Check options for the app container. | <pre>object({<br>    retries     = number<br>    timeout     = number<br>    interval    = number<br>    startPeriod = number<br>  })</pre> | <pre>{<br>  "interval": 5,<br>  "retries": 3,<br>  "startPeriod": 300,<br>  "timeout": 2<br>}</pre> | no |
| <a name="input_ecs_security_group"></a> [ecs\_security\_group](#input\_ecs\_security\_group) | Security group for the  ECS application. | <pre>object({<br>    ingress_rules            = optional(list(string))<br>    ingress_cidr_blocks      = optional(list(string))<br>    ingress_with_cidr_blocks = optional(list(map(string)))<br>    egress_rules             = optional(list(string))<br>    egress_cidr_blocks       = optional(list(string))<br>    egress_with_cidr_blocks  = optional(list(map(string)))<br>    ingress_with_sg          = optional(list(map(string)))<br>    egress_with_sg           = optional(list(map(string)))<br>  })</pre> | `null` | no |
| <a name="input_ecs_exec_role_custom_policy_json"></a> [ecs\_exec\_role\_custom\_policy\_json](#input\_ecs\_exec\_role\_custom\_policy\_json) | Custom policy to attach to ecs task execution role. Document must be valid json. | `string` | `""` | no |
| <a name="input_ecs_role_custom_policy_json"></a> [ecs\_role\_custom\_policy\_json](#input\_ecs\_role\_custom\_policy\_json) | Custom policy to attach to ecs task role. Document must be valid json. | `string` | `""` | no |
| <a name="input_envoy_proxy_image"></a> [envoy\_proxy\_image](#input\_envoy\_proxy\_image) | Optional docker image of the envoy proxy in the format `<docker_image>:<tag>`<br>    Default is `840364872350.dkr.ecr.us-east-2.amazonaws.com/aws-appmesh-envoy:v1.25.4.0-prod` | `string` | `""` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | The launch type of the ECS service. Default is FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The network\_mode of the ECS service. Default is awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ignore_changes_task_definition"></a> [ignore\_changes\_task\_definition](#input\_ignore\_changes\_task\_definition) | Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task\_definition is changed outside of terraform | `bool` | `true` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | If true, public IP will be assigned to this service task, else private IP | `bool` | `false` | no |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | Lifecycle ignore policy for desired\_count. If true, terraform won't detect changes when desired\_count is changed outside of terraform | `bool` | `true` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Amount of CPU to be allocated to the task | `number` | `512` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Amount of Memory to be allocated to the task | `number` | `1024` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers | `number` | `0` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment | `number` | `100` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment | `number` | `200` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_deployment_controller_type"></a> [deployment\_controller\_type](#input\_deployment\_controller\_type) | Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS` | `string` | `"ECS"` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `false` | no |
| <a name="input_redeploy_on_apply"></a> [redeploy\_on\_apply](#input\_redeploy\_on\_apply) | Redeploys the service everytime a terraform apply is executed. force\_new\_deployment should also be true for this flag to work | `bool` | `false` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service when terraform apply is executed. | `bool` | `false` | no |
| <a name="input_create_gateway_route"></a> [create\_gateway\_route](#input\_create\_gateway\_route) | Whether to create an ingress Virtual Gateway route into the ECS application. Default is true<br>    Ingress route can be created in two ways:<br>    - Path matching: The incoming request is checked for a particular path prefix (example: `/app1`) and based on this,<br>      routed to the respective backend virtual service. If this routing is selected, var.match\_path\_prefix is mandatory<br>    - Hostname matching: The incoming request is checked for a particular HostName header (example: `app1.demo.com`<br>      and based on which is routed to the respective backend virtual service. If this routing is selected,<br>      either var.match\_hostname\_exact or var.match\_hostname\_regex is mandatory | `bool` | `true` | no |
| <a name="input_match_path_prefix"></a> [match\_path\_prefix](#input\_match\_path\_prefix) | Gateway route match path prefix. Default is `/`. Conflicts with var.match\_path\_exact and var.match\_path\_regex | `string` | `"/"` | no |
| <a name="input_rewrite_prefix"></a> [rewrite\_prefix](#input\_rewrite\_prefix) | Rewrite the prefix before sending the request to the backend. The supplied prefix will be prepended<br>    For example if the rewrite\_prefix = /test/, then the request /a/b/test.html will be forwarded to the backend<br>    as /test/a/b/test.html | `string` | `""` | no |
| <a name="input_match_hostname_exact"></a> [match\_hostname\_exact](#input\_match\_hostname\_exact) | Gateway route match exact hostname. Conflicts with var.match\_hostname\_suffix | `string` | `null` | no |
| <a name="input_match_hostname_suffix"></a> [match\_hostname\_suffix](#input\_match\_hostname\_suffix) | Gateway route match hostname suffix. Specified ending characters of the host name to match on.<br>    Conflicts with var.match\_hostname\_exact<br>    Example: *.abc.com | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be associated with the resources | `map(string)` | `{}` | no |
| <a name="input_opentelemetry_config_file_contents"></a> [opentelemetry\_config\_file\_contents](#input\_opentelemetry\_config\_file\_contents) | OpenTelemetry Configuration file contents | `string` | `""` | no |
| <a name="input_app_mounts"></a> [app\_mounts](#input\_app\_mounts) | Mount points for the application container | <pre>list(object({<br>    containerPath = string<br>    readOnly      = optional(bool, false)<br>    sourceVolume  = string<br>  }))</pre> | `[]` | no |
| <a name="input_bind_mount_volumes"></a> [bind\_mount\_volumes](#input\_bind\_mount\_volumes) | Extra bind mount volumes to be created for this task | `list(object({ name = string }))` | `[]` | no |
| <a name="input_extra_containers"></a> [extra\_containers](#input\_extra\_containers) | Specifications for containers to be launched in ECS for this task alongside the main app and envoy proxy containers | <pre>list(object({<br>    name                     = string<br>    image_tag                = string<br>    command                  = optional(list(string), [])<br>    essential                = optional(bool, false)<br>    cpu                      = optional(number, 0)<br>    memory                   = optional(number, null)<br>    memory_reservation       = optional(number, null)<br>    readonly_root_filesystem = optional(bool, false)<br>    environment              = optional(map(string), null)<br>    secrets                  = optional(map(string), null)<br>    mount_points = optional(list(object({<br>      containerPath = optional(string)<br>      readOnly      = optional(bool, false)<br>      sourceVolume  = optional(string)<br>    })), [])<br>    port_mappings = optional(list(object({<br>      containerPort = number<br>      hostPort      = optional(number)<br>      protocol      = optional(string, "tcp")<br>    })), [])<br>    healthcheck = optional(object({<br>      retries     = number<br>      command     = list(string)<br>      timeout     = number<br>      interval    = number<br>      startPeriod = number<br>    }), null)<br>    user = optional(string, null)<br>    depends_on = optional(list(object({<br>      containerName = string<br>      condition     = string<br>    })), [])<br>    log_configuration = optional(object({<br>      logDriver = optional(string, "awslogs")<br>      options = object({<br>        awslogs-group         = string<br>        awslogs-region        = string<br>        awslogs-create-group  = optional(string, "true")<br>        awslogs-stream-prefix = string<br>      })<br>    }), null)<br>  }))</pre> | `[]` | no |
| <a name="input_app_depends_on_extra"></a> [app\_depends\_on\_extra](#input\_app\_depends\_on\_extra) | Extra containers on which the main app should depend in order to start | <pre>list(object({<br>    containerName = string<br>    condition     = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | A map of resource\_name\_types to generated resource names used in this module |
| <a name="output_ecs_sg_id"></a> [ecs\_sg\_id](#output\_ecs\_sg\_id) | The ID of the ECS Security Group |
| <a name="output_virtual_node_id"></a> [virtual\_node\_id](#output\_virtual\_node\_id) | ID of the Virtual Node created for the application |
| <a name="output_virtual_service_id"></a> [virtual\_service\_id](#output\_virtual\_service\_id) | ID of the Virtual Service created for the application |
| <a name="output_virtual_node_arn"></a> [virtual\_node\_arn](#output\_virtual\_node\_arn) | ARN of the Virtual Node created for the application |
| <a name="output_virtual_service_arn"></a> [virtual\_service\_arn](#output\_virtual\_service\_arn) | ARN of the Virtual Service created for the application |
| <a name="output_task_definition_name"></a> [task\_definition\_name](#output\_task\_definition\_name) | Task Definition family of the ECS App |
| <a name="output_task_definition_version"></a> [task\_definition\_version](#output\_task\_definition\_version) | Task Definition revision of the ECS App |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | Task Exec role ARN of the ECS App |
| <a name="output_task_exec_role_arn"></a> [task\_exec\_role\_arn](#output\_task\_exec\_role\_arn) | Task role ARN of the ECS App |
| <a name="output_virtual_gateway_route_arn"></a> [virtual\_gateway\_route\_arn](#output\_virtual\_gateway\_route\_arn) | ARN of the Virtual Gateway route for the application |
| <a name="output_virtual_gateway_route_id"></a> [virtual\_gateway\_route\_id](#output\_virtual\_gateway\_route\_id) | ID of the Virtual Gateway route for the application |
| <a name="output_virtual_router_id"></a> [virtual\_router\_id](#output\_virtual\_router\_id) | ID of the Virtual Router (if enabled) |
| <a name="output_virtual_router_arn"></a> [virtual\_router\_arn](#output\_virtual\_router\_arn) | ARN of the Virtual Router (if enabled) |
| <a name="output_virtual_router_name"></a> [virtual\_router\_name](#output\_virtual\_router\_name) | Name of the Virtual Router (if enabled) |
| <a name="output_virtual_router_route_arn"></a> [virtual\_router\_route\_arn](#output\_virtual\_router\_route\_arn) | ARN of the Virtual Router route (if enabled) |
| <a name="output_virtual_router_route_id"></a> [virtual\_router\_route\_id](#output\_virtual\_router\_route\_id) | ID of the Virtual Router route (if enabled) |
| <a name="output_container_json"></a> [container\_json](#output\_container\_json) | Container json for the ECS Task Definition |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
