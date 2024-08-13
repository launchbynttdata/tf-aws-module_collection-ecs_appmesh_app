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
  type        = string
  description = "AWS Region in which the infra needs to be provisioned"
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
    alb_sg = {
      name       = "albsg"
      max_length = 60
    }
    vgw_ecs_sg = {
      name       = "vgwsg"
      max_length = 60
    }
    health_check_app_ecs_sg = {
      name       = "hcappsg"
      max_length = 60
    }
    alb = {
      name       = "alb"
      max_length = 32
    }
    alb_tg = {
      name       = "albtg"
      max_length = 60
    }
    virtual_gateway = {
      name       = "vgw"
      max_length = 60
    }
    sds_vg = {
      name       = "sdsvg"
      max_length = 60
    }
    s3_logs = {
      name       = "alblogs"
      max_length = 60
    }
    acm = {
      name       = "acm"
      max_length = 60
    }
    task_exec_policy = {
      name       = "execplcy"
      max_length = 60
    }
    task_policy = {
      name       = "taskplcy"
      max_length = 60
    }
    vgw_ecs_app = {
      name       = "vgwsvc"
      max_length = 60
    }
    health_check_ecs_app = {
      name       = "hcsvc"
      max_length = 60
    }
    vgw_ecs_td = {
      name       = "vgwtd"
      max_length = 60
    }
    health_check_ecs_td = {
      name       = "hctd"
      max_length = 60
    }
  }
}


### VPC related variables

variable "vpc_cidr" {
  type        = string
  description = "CIDR block related to the VPC"
  default     = "172.31.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
  default     = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
  # These shouldy correspond to the CIDR ranges in the above variable
  default = ["subnet-0f1ca804fd2b81542", "subnet-0d1d4e3959758d4a7", "subnet-049b7adef3cafc0f8"]
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the VPC"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

## VPC Endpoint related
### VPC Endpoints related variables
variable "interface_vpc_endpoints" {
  description = "List of VPC endpoints to be created"
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "gateway_vpc_endpoints" {
  description = "List of VPC endpoints to be created"
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "vpce_security_group" {
  description = "Default security group to be attached to all VPC endpoints"
  type = object({
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    egress_with_cidr_blocks  = optional(list(map(string)))
  })

  default = null
}

## Ingress related

variable "private_ca_arn" {
  description = "ARN of the Private CA. This is used to sign private certificates used in App Mesh. Required when TLS is enabled in App Mesh"
  type        = string
}

variable "app_image_tag" {
  description = "Docker image for the heartBeat application, in the format <docker_image><docker_tag>"
  type        = string
}

variable "app_port" {
  description = "The port at which the health check application is running"
  type        = number
}

variable "app_security_group" {
  description = "Security group for the health check ECS application. Need to open ports if one wants to access the heart-beat application manually."
  type = object({
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    egress_with_cidr_blocks  = optional(list(map(string)))
  })

  default = null
}

variable "tags" {
  description = "A map of custom tags to be associated with the resources"
  type        = map(string)
  default     = {}
}

variable "wait_for_steady_state" {
  type        = bool
  description = "If true, it will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing"
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service when terraform apply is executed."
  type        = bool
  default     = false
}

variable "match_path_prefix" {
  description = "Gateway route match path prefix. Default is `/`. Conflicts with var.match_path_exact and var.match_path_regex"
  type        = string
  default     = "/"
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

## ECS related variables

variable "ecs_cluster_arn" {
  description = "ARN of the ECS Fargate cluster in which the service is to be deployed"
  type        = string
}

variable "ignore_changes_task_definition" {
  description = "Lifecycle ignore policy for task definition. If true, terraform won't detect changes when task_definition is changed outside of terraform"
  type        = bool
  default     = true
}

variable "ignore_changes_desired_count" {
  description = "Lifecycle ignore policy for desired_count. If true, terraform won't detect changes when desired_count is changed outside of terraform"
  type        = bool
  default     = true
}

variable "app_task_cpu" {
  type        = number
  description = "Amount of CPU to be allocated to the task"
  default     = 512
}

variable "app_task_memory" {
  type        = number
  description = "Amount of Memory to be allocated to the task"
  default     = 1024
}

variable "app_desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
}
