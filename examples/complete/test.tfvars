# VPC Information
vpc_cidr           = "10.0.0.0/16"
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
# ECS platform Variables
vpce_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
interface_vpc_endpoints = {
  ecrdkr = {
    service_name        = "ecr.dkr"
    private_dns_enabled = true
  }
  ecrapi = {
    service_name        = "ecr.api"
    private_dns_enabled = true
  }
  ecs = {
    service_name        = "ecs"
    private_dns_enabled = true
  }
  logs = {
    service_name        = "logs"
    private_dns_enabled = true
  }
  appmeshenvoymgmt = {
    service_name        = "appmesh-envoy-management"
    private_dns_enabled = true
  }
  appmesh = {
    service_name        = "appmesh"
    private_dns_enabled = true
  }
}

gateway_vpc_endpoints = {
  s3 = {
    service_name        = "s3"
    private_dns_enabled = true
  }
}
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
# dns_zone_name should be tied to a real domain known to Route 53
dns_zone_name = "sandbox.launch.nttdata.com"
private_zone  = false

# Virtual gateway

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

app_image_tag = "public.ecr.aws/nginx/nginx:latest"
app_port      = 8080


# # ECS AppMesh information

ecs_security_group =  {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}






