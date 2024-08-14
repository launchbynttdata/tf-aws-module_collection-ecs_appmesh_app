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

resource "random_integer" "priority" {
  min = 10000
  max = 50000
}

#TODO: Add more test coverage for what we do have
#TODO: Just bite the bullet and use TLS too
#TODO: Need two services that can talk to each other
#TODO: Need a fargate cluster
#TODO: Need an NLB according to AWS docs
#TODO: Actually need an ALB according to other docs
#TODO: Need to pass a variable into clustered services to indicate which one has been reached

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = join("", split("-", var.region))
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  private_subnets      = var.private_subnet_cidrs
  azs                  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "ecs_platform" {
  source                  = "terraform.registry.launch.nttdata.com/module_collection/ecs_appmesh_platform/aws"
  version                 = "~> 1.0"
  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints
  # Need to inject route_table_ids for gateway endpoints
  route_table_ids = concat([module.vpc.default_route_table_id], module.vpc.private_route_table_ids)

  logical_product_family     = var.logical_product_family
  logical_product_service    = var.logical_product_service
  vpce_security_group        = var.vpce_security_group
  region                     = var.region
  environment                = var.class_env
  environment_number         = var.instance_env
  resource_number            = var.instance_resource
  container_insights_enabled = true

  namespace_name        = var.namespace_name
  namespace_description = "Namespace for testing appmesh app"

  tags = local.tags
}

module "virtual_gateway" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_gateway/aws"
  version = "~> 1.0"

  name      = module.resource_names["virtual_gateway"].standard
  mesh_name = local.app_mesh_name

  tls_enforce           = var.tls_enforce
  health_check_path     = var.vgw_health_check_path
  health_check_port     = var.vgw_listener_port
  health_check_protocol = var.vgw_health_check_protocol
  listener_port         = var.vgw_listener_port
  listener_protocol     = var.vgw_listener_protocol
  tls_mode              = var.vgw_tls_mode
  text_format           = var.vgw_logs_text_format

  tags = merge(local.tags, { resource_name = module.resource_names["virtual_gateway"].standard })
}

module "ecs_appmesh_app1" {
  source = "../.."

  logical_product_family = var.logical_product_family
  # This is essential to keep unique IAM policy names
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  region                  = var.region
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource

  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  namespace_name       = var.namespace_name
  namespace_id         = var.namespace_id
  app_mesh_id          = var.app_mesh_id
  virtual_gateway_name = module.virtual_gateway.name

  private_ca_arn     = var.private_ca_arn
  ecs_cluster_arn    = var.ecs_cluster_arn
  app_image_tag      = var.app_image_tag
  app_ports          = [var.app_port]
  ecs_security_group = var.app_security_group

  # should be same has ALB TG health check path
  match_path_prefix = var.match_path_prefix

  task_cpu                       = var.app_task_cpu
  task_memory                    = var.app_task_memory
  desired_count                  = var.app_desired_count
  force_new_deployment           = var.force_new_deployment
  ignore_changes_desired_count   = var.ignore_changes_desired_count
  ignore_changes_task_definition = var.ignore_changes_task_definition
  wait_for_steady_state          = var.wait_for_steady_state

  tags = local.tags

  depends_on = [module.virtual_gateway]
}
