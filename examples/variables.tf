# VPC Information
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets."
  type        = list(string)
}

# ECS Platfom Information
variable "gateway_vpc_endpoints" {
  description = "List of VPC endpoints to be created. AWS currently only supports S3 and DynamoDB gateway interfaces"
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    route_table_ids     = optional(list(string))
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "interface_vpc_endpoints" {
  description = <<EOT
    List of VPC endpoints to be created. Must create endpoints for all AWS services that the ECS services
    needs to communicate over the private network. For example: ECR, CloudWatch, AppMesh etc. In absence of
    NAT gateway, pull images from ECR too needs private endpoint.
  EOT
  type = map(object({
    service_name        = string
    subnet_names        = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))

  default = {}
}

variable "vpce_security_group" {
  description = "Default security group to be attached to all VPC endpoints. Must allow relevant ingress and egress traffic."
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

variable "namespace_description" {
  description = "Namespace description"
  type        = string
  default = ""
}

# ECS AppMesh Information
variable "namespace_name" {
  description = "The name of the service discovery namespace."
  type        = string
  default = "appmesh_app"
}

variable "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  type        = string
}

variable "app_mesh_id" {
  description = "The ID of the AWS App Mesh."
  type        = string
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

# Application-specific information
variable "app_image_tag" {
  description = "The tag of the application container image."
  type        = string
}

variable "app_port" {
  description = "The port for the application."
  type        = number
}

# Additional required arguments for ecs_appmesh_ingress module
variable "vgw_listener_port" {
  description = "Listener port for the virtual gateway."
  type        = number
}

variable "target_groups" {
  description = "List of target group configurations for the application."
  type = list(object({
    name     = string
    port     = number
    protocol = string
  }))
}

variable "dns_zone_name" {
  description = "DNS zone name for the application."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

variable "logical_product_family" {
  description = "The logical product family name"
  type        = string
 default = "terratest"
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


variable "logical_product_service" {
  description = "The logical product service name"
  type        = string
  default = "ecs_appmesh_app"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-2"
}

variable "app_health_check_path" {
  description = "The health check path for the application"
  type        = string
}

variable "namespace_id" {
  description = "The ID of the service discovery namespace."
  type        = string
}

variable "virtual_gateway_name" {
  description = "Name of the Virtual gateway in which gateway route will be created"
  type        = string
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
}

# variable ECS_ingress

variable "alb_sg" {
  description = "Security Group for the ALB. https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf"
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

variable "vgw_security_group" {
  description = "Security group for the Virtual Gateway ECS application. By default, it allows traffic from ALB on the app_port"
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

variable "virtual_node_app_health_check_path" {
  description = "The health check path for the virtual node"
  type        = string
  default = "/health"
}

variable "app_ports" {
  description = "The port(s) at which the application is running, used as listeners in Virtual Node."
  type        = list(number)
  default = [ 8080 ]
}

variable "ecs_security_group" {
  description = "Security group for the  ECS application. Must allow the ingress from the virtual gateway on app port"
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

variable "private_zone" {
  description = <<EOT
    Whether the dns_zone_name provided above is a private or public hosted zone. Required if dns_zone_name is not empty.
    private_zone=true means the hosted zone is private and false means it is public.
  EOT
  type        = bool
  default     = "false"
}