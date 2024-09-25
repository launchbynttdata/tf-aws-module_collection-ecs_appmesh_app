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

module "ecs_example" {
  source = "../.."

  logical_product_family  = "terratest"
  logical_product_service = "ecs_appmesh"
  class_env               = "dev"
  instance_env            = 1
  instance_resource       = 1
  region                  = "us-east-1"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  namespace_name  = "<namespace_name>"
  namespace_id    = "<namespace_id>"
  ecs_cluster_arn = "<ecs_cluster_arn>"
  app_mesh_id     = "<app_mesh_id>"

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
