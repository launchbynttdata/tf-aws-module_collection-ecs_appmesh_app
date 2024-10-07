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

# ecs_plateform Module
module "ecs_platform" {
  source                  = "terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws"
  version                 = "~> 1.0"
  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints
  route_table_ids         = [module.vpc.default_route_table_id]
  logical_product_family     = var.logical_product_family
  logical_product_service    = local.logical_product_service
  vpce_security_group        = var.vpce_security_group
  region                     = var.aws_region
  namespace_name             = var.namespace_name
  tags = var.tags
}

# #ECS AppMesh Ingress Module
module "ecs_ingress" {
  source          = "terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_ingress/aws"
  version                 = "~> 1.1"
  class_env         = var.class_env
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  namespace_name  = module.ecs_platform.namespace_name
  namespace_id    = module.ecs_platform.namespace_id
  ecs_cluster_arn = module.ecs_platform.fargate_arn
  app_mesh_id     = module.ecs_platform.app_mesh_id
  private_ca_arn = module.private_ca.private_ca_arn
  
  alb_sg              = var.alb_sg
  use_https_listeners = true
  private_zone        = var.private_zone
  
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
module "private_ca" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_ca/aws"
  version = "~> 1.0"

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service

  tags = var.tags
}

# # ECS AppMesh Module

module "ecs_appmesh_app" {
  source = "../.."
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  region                  = var.aws_region

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  namespace_name  = local.namespace_name
  namespace_id    = var.namespace_id
  ecs_cluster_arn = module.ecs_platform.fargate_arn 
  app_mesh_id     = module.ecs_platform.app_mesh_id
  private_ca_arn = module.private_ca.private_ca_arn

  app_ports                          = var.app_ports
  app_image_tag                      = var.app_image_tag
  app_health_check_path              = var.app_health_check_path
  virtual_node_app_health_check_path = var.virtual_node_app_health_check_path
  virtual_gateway_name = module.ecs_ingress.virtual_gateway_name

  ecs_security_group = var.ecs_security_group
  
  
  autoscaling_enabled            = var.autoscaling_enabled
  force_new_deployment           = true
  redeploy_on_apply              = true  
  ignore_changes_desired_count   = false
  ignore_changes_task_definition = false
  wait_for_steady_state          = false

  desired_count     = var.desired_count
  match_path_prefix = "/"
  tags = {
    "Owner" = "dev team"
  }
  
  
}



