
provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  private_subnets      = var.private_subnets
  azs                  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "example-vpc"
    Environment = "dev"
  }
}

module "ecs_platform" {
  source                  = "terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws"
  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints
  route_table_ids         = [module.vpc.default_route_table_id]
  logical_product_family     = var.logical_product_family
  logical_product_service    = local.logical_product_service
  vpce_security_group        = var.vpce_security_group
  region                     = var.aws_region
  tags = var.tags
}


# ECS AppMesh Ingress Module
module "ecs_ingress" {
  source          = "terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_ingress/aws"

  class_env         = var.class_env
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  namespace_name  = module.ecs_platform.namespace_name
  namespace_id    = module.ecs_platform.namespace_id
  ecs_cluster_arn = module.ecs_platform.fargate_arn
  app_mesh_id     = module.ecs_platform.app_mesh_id

  alb_sg              = var.alb_sg
  use_https_listeners = true

  dns_zone_name = lower(var.dns_zone_name)
  target_groups = [
    {
      backend_protocol = "https"
      backend_port     = 443
      target_type      = "ip"
      health_check = {
        port                = 443
        path                = "/health"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        protocol            = "HTTPS"
      }
    }
  ]

  ignore_changes_desired_count      = false
  ignore_changes_task_definition    = false

  tls_enforce               = true
  vgw_health_check_path     = "/"
  vgw_health_check_protocol = "http"
  vgw_listener_port         = 443
  vgw_listener_protocol     = "http"
  vgw_tls_mode              = "STRICT"
  vgw_security_group        = var.vgw_security_group

  app_port           = var.app_port
  app_image_tag      = var.app_image_tag
  match_path_prefix  = "/health"
  tags = var.tags
  depends_on = [module.ecs_platform, module.vpc]
}

# ECS AppMesh Module

module "ecs_appmesh" {
  source = "../"

  logical_product_family  = "terratest"
  logical_product_service = "ecs_appmesh"
  class_env               = "dev"
  instance_env            = 1
  instance_resource       = 1
  region                  = "us-east-1"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  namespace_name  = local.namespace_name
  namespace_id    = var.namespace_id
  ecs_cluster_arn = var.ecs_cluster_arn
  app_mesh_id     = var.app_mesh_id

  app_ports                          = [8080]
  app_image_tag                      = "myapp:latest"
  app_health_check_path              = "/health"
  virtual_node_app_health_check_path = "/health"

  ecs_security_group = {
    ingress_rules       = ["https-443-tcp", "http-80-tcp"]
    ingress_cidr_blocks = ["0.0.0.0/0"]
    egress_rules        = ["all-all"]
    egress_cidr_blocks  = ["0.0.0.0/0"]
  }

  force_new_deployment           = true
  redeploy_on_apply              = true
  ignore_changes_desired_count   = false
  ignore_changes_task_definition = false
  wait_for_steady_state          = false

  desired_count     = 1
  match_path_prefix = "/"
  tags = {
    "Owner" = "Example Team"
  }

  virtual_gateway_name = "<your-virtual-gateway-name>"
}



