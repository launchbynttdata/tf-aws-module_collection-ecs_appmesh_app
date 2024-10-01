# VPC Information
vpc_cidr           = "10.0.0.0/16"
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]

# ECS platform Variables
vpce_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

# ECS AppMesh Variables
namespace_name        = "my-namespace"
namespace_id          = "ns-xyz123"
ecs_cluster_arn       = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
app_mesh_id           = "mesh-abc456"
app_image_tag         = "myapp:latest"
app_port              = 8080
app_health_check_path = "/health"
alb_sg = {
  description         = "Security group for ALB"
  ingress_cidr_blocks = ["10.1.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    },
    {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
virtual_gateway_name  = "my-virtual-gateway"

# Required arguments for ecs_appmesh_ingress module
vgw_listener_port = 80
target_groups = [
  {
    name     = "my-target-group"
    port     = 8080
    protocol = "HTTP"
  }
]
dns_zone_name = "example.com"
desired_count = 1
tags = {
  "Owner"       = "Example Team"
  "Environment" = "dev"
}

vgw_security_group = {
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port = 9901
      to_port   = 9901
      protocol  = "tcp"
    },
    {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  ]
}

