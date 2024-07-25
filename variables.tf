// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false
  default     = "launch"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false
  default     = "backend"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 1 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 1 to 100."
  }
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  type        = string
  default     = "us-east-2"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    app_ecs_sg = {
      name       = "app-sg"
      max_length = 60
    }
    virtual_service = {
      name       = "vsvc"
      max_length = 60
    }
    virtual_node = {
      name       = "vnode"
      max_length = 60
    }
    virtual_router = {
      name       = "vrouter"
      max_length = 60
    }
    router_route = {
      name       = "vroute"
      max_length = 60
    }
    gateway_route = {
      name       = "gwroute"
      max_length = 60
    }
    acm = {
      name       = "acm"
      max_length = 60
    }
    service_discovery_service = {
      # should be same as the service disovery service used in the ECS service
      name       = "vsvc"
      max_length = 60
    }
    task_exec_role = {
      name       = "exec-role"
      max_length = 60
    }
    task_role = {
      name       = "task-role"
      max_length = 60
    }
    task_exec_policy = {
      name       = "exec-plcy"
      max_length = 60
    }
    task_policy = {
      name       = "task-plcy"
      max_length = 60
    }
    ecs_app = {
      name       = "svc"
      max_length = 60
    }
    ecs_td = {
      name       = "td"
      max_length = 60
    }
  }
}

### VPC related variables
variable "vpc_id" {
  description = "The VPC ID of the VPC where infrastructure will be provisioned"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

### Cloud Map Namespace related variables

variable "namespace_name" {
  description = "Namespace name of the CloudMap namespace which the Virtual Node references."
  type        = string
}

variable "namespace_id" {
  description = "ID of the CloudMap namespace in which SDS to be created."
  type        = string
}

## App Mesh related variables

variable "app_mesh_id" {
  description = "Id/Name of the App Mesh"
  type        = string
}

variable "virtual_gateway_name" {
  description = "Name of the Virtual gateway in which gateway route will be created"
  type        = string
}

variable "private_ca_arn" {
  description = "ARN of the Private CA. This is used to sign private certificates used in App Mesh. Required when TLS is enabled in App Mesh"
  type        = string
  default     = ""
}

variable "tls_enforce" {
  description = "Whether to enforce TLS in App Mesh Virtual Service/Node"
  type        = bool
  default     = true
}

## Virtual Router
variable "enable_virtual_router" {
  description = "Whether to create a Virtual Router and route traffic to virtual Node via it"
  type        = bool
  default     = true
}

variable "router_retry_policy" {
  description = "Rules for retry policies to be applied to this route"
  type = object({
    http_retry_events = list(string)
    max_retries       = number
    per_entry_timeout = object({
      unit  = string
      value = number
    })
    tcp_retry_events = list(string)
  })

  default = null
}

## Virtual Node related variables

variable "app_ports" {
  description = "The port(s) at which the application is running. These ports will be accessed by the mitm-proxy to forward traffic."
  type        = list(number)
  default     = []
}

variable "mitm_proxy_ports" {
  description = "The port(s) at which the mitm_proxy (encoder) is running. The same ports are used as listeners in Virtual Node"
  type        = list(number)
  default     = []
}

variable "virtual_node_app_health_check_path" {
  description = <<EOT
    Path in the app for Virtual Node to perform health check.
    If empty, then no health check is configured on the Virtual Node
    Note: Virtual node just logs the health check output to envoy proxy logs, but doesn't evict
    the unhealthy containers.
  EOT

  type    = string
  default = "/"
}

variable "idle_duration" {
  description = "Idle duration for all the listeners"
  type = object({
    unit  = string
    value = number
  })
  default = null
}

variable "per_request_timeout" {
  description = "Per Request timeout for all the listeners"
  type = object({
    unit  = string
    value = number
  })
  default = null
}

## ECS related variables

variable "print_container_json" {
  description = "Print the container JSON object as output. Useful for debugging"
  type        = bool
  default     = false
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS Fargate cluster in which the service is to be deployed"
  type        = string
}

variable "app_image_tag" {
  description = "The docker image of the application in the format <docker_image>:<tag>"
  type        = string
}

variable "app_environment" {
  description = "Environment variables to be injected into the application containers"
  type        = map(string)
  default     = {}
}

variable "app_secrets" {
  description = "Secrets to be injected into the application containers. Map of secret Manager ARNs"
  type        = map(string)
  default     = {}
}

variable "mitm_proxy_image_tag" {
  description = "The docker image of the mitm-proxy in the format <docker_image>:<tag>"
  type        = string
  default     = ""
}

variable "mitm_proxy_environment" {
  description = "Environment variables to be injected into the mitm-proxy encoder container"
  type        = map(string)
  default     = {}
}

variable "mitm_proxy_secrets" {
  description = "Secrets to be injected into the mitm-proxy encoder container. Map of secret Manager ARNs"
  type        = map(string)
  default     = {}
}

variable "autoscaling_enabled" {
  description = "Flag to determine if auto scaling is enabled for the application"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Min capacity of the scalable target."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Max capacity of the scalable target."
  type        = number
  default     = 4
}

variable "autoscaling_policies" {
  description = <<EOT
    A map of autoscaling policies to be created for this ECS Service
    The `predefined_metric_type` must be ECSServiceAverageCPUUtilization or ECSServiceAverageMemoryUtilization
    `target_value` is the threshold for the metric at which the auto-scaling will be triggerred.
    `scale_in_cooldown` and `scale_out_cooldown` respectively are amount of time, in seconds, after a scale in activity
      completes before another scale in activity can start.
  EOT
  type = map(object({
    predefined_metric_type = string
    target_value           = string
    scale_in_cooldown      = optional(string, 60)
    scale_out_cooldown     = optional(string, 60)
  }))

  default = {}
}

variable "app_health_check_path" {
  description = <<EOT
    A path of the health endpoint inside the container for Container level health check. Example. `/health`.
    The complete health check would be http://localhost:<container_port>/health
    By default is no health check configured

  EOT
  type        = string
  default     = ""
}

variable "app_health_check_options" {
  description = "Health Check options for the app container."
  type = object({
    retries     = number
    timeout     = number
    interval    = number
    startPeriod = number
  })

  default = {
    retries     = 3
    timeout     = 2
    interval    = 5
    startPeriod = 300
  }
}

variable "ecs_security_group" {
  description = "Security group for the  ECS application."
  type = object({
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    egress_with_cidr_blocks  = optional(list(map(string)))
    ingress_with_sg          = optional(list(map(string)))
    egress_with_sg           = optional(list(map(string)))
  })

  default = null
}

variable "ecs_exec_role_custom_policy_json" {
  description = "Custom policy to attach to ecs task execution role. Document must be valid json."
  type        = string
  default     = ""
}

variable "ecs_role_custom_policy_json" {
  description = "Custom policy to attach to ecs task role. Document must be valid json."
  type        = string
  default     = ""
}

variable "envoy_proxy_image" {
  description = <<EOT
    Optional docker image of the envoy proxy in the format `<docker_image>:<tag>`
    Default is `840364872350.dkr.ecr.us-east-2.amazonaws.com/aws-appmesh-envoy:v1.25.4.0-prod`
  EOT
  type        = string
  default     = ""
}

variable "ecs_launch_type" {
  description = "The launch type of the ECS service. Default is FARGATE"
  type        = string
  default     = "FARGATE"
}

variable "network_mode" {
  description = "The network_mode of the ECS service. Default is awsvpc"
  type        = string
  default     = "awsvpc"
}

variable "ignore_changes_task_definition" {
  description = "Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task_definition is changed outside of terraform"
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "If true, public IP will be assigned to this service task, else private IP"
  type        = bool
  default     = false
}

variable "ignore_changes_desired_count" {
  description = "Lifecycle ignore policy for desired_count. If true, terraform won't detect changes when desired_count is changed outside of terraform"
  type        = bool
  default     = true
}

variable "task_cpu" {
  type        = number
  description = "Amount of CPU to be allocated to the task"
  default     = 512
}

variable "task_memory" {
  type        = number
  description = "Amount of Memory to be allocated to the task"
  default     = 1024
}
variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers"
  default     = 0
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment"
  default     = 100
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment"
  default     = 200
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
}

variable "deployment_controller_type" {
  type        = string
  description = "Type of deployment controller. Valid values are `CODE_DEPLOY` and `ECS`"
  default     = "ECS"
}

variable "wait_for_steady_state" {
  type        = bool
  description = "If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing"
  default     = false
}

variable "redeploy_on_apply" {
  description = "Redeploys the service everytime a terraform apply is executed. force_new_deployment should also be true for this flag to work"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service when terraform apply is executed."
  type        = bool
  default     = false
}

## Gateway Route related variables

variable "create_gateway_route" {
  description = <<EOT
    Whether to create an ingress Virtual Gateway route into the ECS application. Default is true
    Ingress route can be created in two ways:
    - Path matching: The incoming request is checked for a particular path prefix (example: `/app1`) and based on this,
      routed to the respective backend virtual service. If this routing is selected, var.match_path_prefix is mandatory
    - Hostname matching: The incoming request is checked for a particular HostName header (example: `app1.demo.com`
      and based on which is routed to the respective backend virtual service. If this routing is selected,
      either var.match_hostname_exact or var.match_hostname_regex is mandatory
  EOT
  type        = bool
  default     = true
}

variable "match_path_prefix" {
  description = "Gateway route match path prefix. Default is `/`. Conflicts with var.match_path_exact and var.match_path_regex"
  type        = string
  default     = "/"
}

variable "rewrite_prefix" {
  description = <<EOT
    Rewrite the prefix before sending the request to the backend. The supplied prefix will be prepended
    For example if the rewrite_prefix = /test/, then the request /a/b/test.html will be forwarded to the backend
    as /test/a/b/test.html

    EOT
  type        = string
  default     = ""
}

variable "match_hostname_exact" {
  description = "Gateway route match exact hostname. Conflicts with var.match_hostname_suffix"
  type        = string
  default     = null
}

variable "match_hostname_suffix" {
  description = <<EOT
    Gateway route match hostname suffix. Specified ending characters of the host name to match on.
    Conflicts with var.match_hostname_exact
    Example: *.abc.com
  EOT
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to be associated with the resources"
  type        = map(string)
  default     = {}
}

variable "opentelemetry_config_file_contents" {
  description = "OpenTelemetry Configuration file contents"
  type        = string
  default     = ""
}


variable "app_mounts" {
  description = "Mount points for the application container"
  type = list(object({
    containerPath = string
    readOnly      = optional(bool, false)
    sourceVolume  = string
  }))
  default = []
}

variable "bind_mount_volumes" {
  description = "Extra bind mount volumes to be created for this task"
  type        = list(object({ name = string }))
  default     = []
}
variable "extra_containers" {
  description = "Specifications for containers to be launched in ECS for this task alongside the main app and envoy proxy containers"
  type = list(object({
    name                     = string
    image_tag                = string
    command                  = optional(list(string), [])
    essential                = optional(bool, false)
    cpu                      = optional(number, 0)
    memory                   = optional(number, null)
    memory_reservation       = optional(number, null)
    readonly_root_filesystem = optional(bool, false)
    environment              = optional(map(string), null)
    secrets                  = optional(map(string), null)
    mount_points = optional(list(object({
      containerPath = optional(string)
      readOnly      = optional(bool, false)
      sourceVolume  = optional(string)
    })), [])
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string, "tcp")
    })), [])
    healthcheck = optional(object({
      retries     = number
      command     = list(string)
      timeout     = number
      interval    = number
      startPeriod = number
    }), null)
    user = optional(string, null)
    depends_on = optional(list(object({
      containerName = string
      condition     = string
    })), [])
    log_configuration = optional(object({
      logDriver = optional(string, "awslogs")
      options = object({
        awslogs-group         = string
        awslogs-region        = string
        awslogs-create-group  = optional(string, "true")
        awslogs-stream-prefix = string
      })
    }), null)
  }))
  default = []
}

variable "app_depends_on_extra" {
  description = "Extra containers on which the main app should depend in order to start"
  type = list(object({
    containerName = string
    condition     = string
  }))
  default = []
}
