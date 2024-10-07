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

variable "namespace_name" {
  description = "The name of the service discovery namespace."
  type        = string
  default = "sandbox.launch.nttdata.local"
}
variable "logical_product_service" {
  description = "The logical product service name"
  type        = string
  default = "int-ing"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Map of custom tags"
  type        = map(string)
  default     = {}
}

variable "logical_product_family" {
  description = "The logical product family name"
  type        = string
   default = "launch"
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

# # variable ECS_ingress

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

}

variable "app_port" {
  description = "The port for the application."
  type        = number
}

variable "app_image_tag" {
  description = "The tag of the application container image."
  type        = string
}

variable "dns_zone_name" {
  description = "DNS zone name for the application."
  type        = string
}

variable "private_zone" {
  description = "Whether the dns_zone_name provided above is a private or public hosted zone. Required if dns_zone_name is not empty"
  type        = string
}

variable "trust_acm_certificate_authority_arns" {
  description = "One or more Amazon Resource Names (ARNs)."
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  type        = string
  default = "aws:ecs:us-east-1:020127659860:cluster/launch-int-ing-useast1-dev-000-fargate-000"

}

# variable "app_mesh_name" {

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

variable "app_health_check_path" {
  description = "The health check path for the application"
  type        = string
  default = "/health"
}

variable "namespace_id" {
  description = "The ID of the service discovery namespace."
  type        = string
  default = "ns-igvzix3mexec23ta"
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
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

variable "autoscaling_enabled" {
  description = "Flag to determine if auto scaling is enabled for the application"
  type        = bool
  default     = true
}

