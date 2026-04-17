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
  description = "Name of the product family for which the resource is created."
  default     = "launch"
}

variable "logical_product_service" {
  type        = string
  description = "Name of the product service for which the resource is created."
  default     = "appmeshapp"
}

variable "class_env" {
  type        = string
  description = "Environment where resource is going to be deployed."
  default     = "sandbox"
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0
}

variable "region" {
  type        = string
  description = "AWS Region in which the infra needs to be provisioned."
  default     = "us-east-2"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block related to the VPC."
  default     = "10.1.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet cidrs."
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the VPC."
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "interface_vpc_endpoints" {
  description = "List of VPC interface endpoints to be created."
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "gateway_vpc_endpoints" {
  description = "List of VPC gateway endpoints to be created."
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "vpce_security_group" {
  description = "Default security group to be attached to all VPC endpoints."
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

variable "private_ca_arn" {
  description = "ARN of the Private CA used to sign private certificates used in App Mesh."
  type        = string
}

variable "alb_sg" {
  description = "Security Group for the ALB."
  type = object({
    description              = optional(string)
    ingress_rules            = optional(list(string))
    ingress_cidr_blocks      = optional(list(string))
    egress_rules             = optional(list(string))
    egress_cidr_blocks       = optional(list(string))
    ingress_with_cidr_blocks = optional(list(map(string)))
    egress_with_cidr_blocks  = optional(list(map(string)))
  })
}

variable "dns_zone_name" {
  description = "Name of the Route53 DNS Zone where custom DNS records will be created."
  type        = string
}

variable "private_zone" {
  description = "Whether the dns_zone_name provided above is a private or public hosted zone."
  type        = bool
}

variable "vgw_security_group" {
  description = "Security group for the Virtual Gateway ECS application."
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

variable "ingress_app_port" {
  description = "Port used by the ingress heartbeat application."
  type        = number
  default     = 8080
}

variable "ingress_app_image_tag" {
  description = "Docker image for the ingress heartbeat application."
  type        = string
}

variable "ingress_app_security_group" {
  description = "Security group for the ingress heartbeat application."
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

variable "app_ports" {
  description = "Ports at which the application is running."
  type        = list(number)
}

variable "app_image_tag" {
  description = "Docker image of the application in the format <docker_image>:<tag>."
  type        = string
}

variable "app_health_check_path" {
  description = "Path of the health endpoint inside the app container."
  type        = string
  default     = ""
}

variable "virtual_node_app_health_check_path" {
  description = "Path in the app for Virtual Node to perform health check."
  type        = string
  default     = "/"
}

variable "ecs_security_group" {
  description = "Security group for the ECS application."
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

variable "force_new_deployment" {
  description = "Enable to force a new task deployment when terraform apply is executed."
  type        = bool
  default     = true
}

variable "redeploy_on_apply" {
  description = "Redeploy the service every time terraform apply is executed."
  type        = bool
  default     = true
}

variable "ignore_changes_desired_count" {
  description = "Lifecycle ignore policy for desired_count."
  type        = bool
  default     = false
}

variable "ignore_changes_task_definition" {
  description = "Lifecycle ignore policy for task_definition."
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "Whether to wait for ECS service steady state."
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Desired ECS service count."
  type        = number
  default     = 1
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period for the ingress ECS service."
  type        = number
  default     = 120
}

variable "match_path_prefix" {
  description = "Path prefix to match in the ingress URL for this app."
  type        = string
  default     = "/app"
}

variable "tags" {
  description = "A map of custom tags to be associated with the resources."
  type        = map(string)
  default     = {}
}
