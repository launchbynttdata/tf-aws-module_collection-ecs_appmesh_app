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

# Security Group configuration


# Virtual Gateway configuration
variable "virtual_gateway_name" {
  description = "Name of the AppMesh virtual gateway."
  type        = string
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
 default = "launch"
}

variable "logical_product_service" {
  description = "The logical product service name"
  type        = string
  default = "ecs"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

# variable "app_ports" {
#   description = "The ports the application uses"
#   type        = list(number)
# }

variable "desired_count" {
  description = "The desired number of ECS tasks"
  type        = number
}

variable "app_health_check_path" {
  description = "The health check path for the application"
  type        = string
}

variable "namespace_id" {
  description = "The ID of the service discovery namespace."
  type        = string
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

# variable "virtual_node_app_health_check_path" {
#   description = "The health check path for the virtual node"
#   type        = string
# }

# variable "ecs_security_group" {
#   description = "Security group configuration for ECS"
#   type = object({
#     ingress_rules = list(object({
#       from_port   = number
#       to_port     = number
#       protocol    = string
#       description = string
#     }))
#     ingress_cidr_blocks = list(string)
#     egress_rules = list(object({
#       from_port   = number
#       to_port     = number
#       protocol    = string
#       description = string
#     }))
#     egress_cidr_blocks = list(string)
#   })
# }
