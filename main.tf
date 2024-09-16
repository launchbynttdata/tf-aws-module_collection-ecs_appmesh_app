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

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

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

# Service Discovery services for Virtual Service
# The service discovery name should be the same name that is used in ECS service for discovery. The private certs
# below must be provisioned for this name
module "sds" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/service_discovery_service/aws"
  version = "~> 1.0"

  name         = module.resource_names["service_discovery_service"].standard
  namespace_id = var.namespace_id

  tags = merge(local.tags, { resource_name = module.resource_names["service_discovery_service"].standard })
}

# Create private certificates for virtual Service
module "private_cert" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/acm_private_cert/aws"
  version = "~> 1.0"

  count = var.tls_enforce ? 1 : 0

  private_ca_arn = var.private_ca_arn
  # This domain name should be the SDS domain name used in the ECS service and must be < 64 characters
  domain_name               = local.updated_domain_name
  subject_alternative_names = local.private_cert_san

  tags = merge(local.tags, { resource_name = module.resource_names["virtual_service"].standard })
}

module "virtual_router" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_router/aws"
  version = "~> 1.0"

  count = var.enable_virtual_router ? 1 : 0

  app_mesh_name = var.app_mesh_id
  name          = module.resource_names["virtual_router"].standard
  listeners = [for port in var.app_ports : {
    protocol = "http"
    port     = port
  }]

  tags = merge(local.tags, { resource_name = module.resource_names["virtual_router"].standard })
}

module "virtual_route" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/appmesh_route/aws"
  version = "~> 1.0"

  count = var.enable_virtual_router ? 1 : 0

  name                = module.resource_names["router_route"].standard
  priority            = 0
  app_mesh_name       = var.app_mesh_id
  virtual_router_name = module.virtual_router[0].name
  virtual_router_port = length(var.app_ports) > 0 ? var.app_ports[0] : null
  route_targets = [
    {
      virtual_node_name = module.virtual_node.name
      virtual_node_port = length(var.app_ports) > 0 ? var.app_ports[0] : null
      weight            = 100
    }
  ]
  idle_duration       = var.idle_duration
  per_request_timeout = var.per_request_timeout
  match_path_prefix   = "/"
  retry_policy        = var.router_retry_policy

  tags = merge(local.tags, { resource_name = module.resource_names["router_route"].standard })

  depends_on = [module.virtual_router]

}

# Virtual Node is the backend for Virtual Service and it connects the virtual service with the ECS Service using Service Discovery
module "virtual_node" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_node/aws"
  version = "~> 1.0"

  app_mesh_id                = var.app_mesh_id
  name                       = module.resource_names["virtual_node"].standard
  namespace_name             = var.namespace_name
  service_name               = module.resource_names["virtual_service"].standard
  tls_enforce                = var.tls_enforce
  ports                      = var.app_ports
  protocol                   = "http"
  certificate_authority_arns = [var.private_ca_arn]
  acm_certificate_arn        = var.tls_enforce ? module.private_cert[0].certificate_arn : null
  health_check_path          = var.virtual_node_app_health_check_path
  idle_duration              = var.idle_duration
  per_request_timeout        = var.per_request_timeout

  tags = merge(local.tags, { resource_name = module.resource_names["virtual_node"].standard })

  depends_on = [module.sds]

}

# A virtual service for the ECS app
module "virtual_service" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_service/aws"
  version = "~> 1.0"

  name                = module.resource_names["virtual_service"].standard
  app_mesh_name       = var.app_mesh_id
  virtual_node_name   = var.enable_virtual_router ? "" : module.virtual_node.name
  virtual_router_name = var.enable_virtual_router ? module.virtual_router[0].name : ""

  tags = merge(local.tags, { resource_name = module.resource_names["virtual_service"].standard })
}

module "gateway_route" {
  # If the service needs an ingress from the outside, a gateway route needs to be created
  count = var.create_gateway_route ? 1 : 0

  source  = "terraform.registry.launch.nttdata.com/module_primitive/appmesh_gateway_route/aws"
  version = "~> 1.0"

  name                 = module.resource_names["gateway_route"].standard
  virtual_gateway_name = var.virtual_gateway_name
  virtual_service_name = module.resource_names["virtual_service"].standard
  # Currently supports only 1 gateway route for the first port in the list of application ports. Need to strategize support of multiple ports
  # The traffic is forwarded as: vgw -> app_envoy -> app
  virtual_service_port = length(var.app_ports) > 0 ? var.app_ports[0] : null
  app_mesh_name        = var.app_mesh_id

  match_hostname_exact  = var.match_hostname_exact
  match_hostname_suffix = var.match_hostname_suffix
  match_path_prefix     = var.match_path_prefix
  rewrite_prefix        = var.rewrite_prefix

  tags = merge(local.tags, { resource_name = module.resource_names["gateway_route"].standard })

  depends_on = [module.virtual_service, module.virtual_node]
}

# The permissions needed by ECS task to start
module "ecs_task_execution_policy" {
  count = length(var.ecs_exec_role_custom_policy_json) > 0 ? 1 : 0

  source  = "cloudposse/iam-policy/aws"
  version = "~> 0.4.0"

  enabled                       = true
  namespace                     = "${var.logical_product_family}-${join("", split("-", var.region))}"
  stage                         = var.instance_env
  environment                   = var.class_env
  name                          = "${var.logical_product_family}-${var.logical_product_service}-${var.resource_names_map["task_exec_policy"].name}-${var.instance_resource}"
  iam_policy_enabled            = true
  iam_override_policy_documents = [var.ecs_exec_role_custom_policy_json]
}

# The permissions needed by the application in the task to run
module "ecs_task_policy" {

  source  = "cloudposse/iam-policy/aws"
  version = "~> 0.4.0"

  enabled                     = true
  namespace                   = "${var.logical_product_family}-${join("", split("-", var.region))}"
  stage                       = var.instance_env
  environment                 = var.class_env
  name                        = "${var.logical_product_family}-${var.logical_product_service}-${var.resource_names_map["task_policy"].name}-${var.instance_resource}"
  iam_policy_enabled          = true
  iam_source_policy_documents = local.ecs_role_custom_policy_json
}

module "container_definitions" {
  source   = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.59.0"
  for_each = local.containers

  command                      = lookup(each.value, "command", null)
  container_name               = each.value.name
  container_image              = each.value.image_tag
  container_memory             = each.value.memory
  container_memory_reservation = each.value.memory_reservation
  container_cpu                = each.value.cpu
  essential                    = each.value.essential
  readonly_root_filesystem     = each.value.readonly_root_filesystem
  map_environment              = merge({ for key, value in each.value.environment : key => key == "OTEL_CONFIG_FILE_CONTENTS" && length(var.opentelemetry_config_file_contents) > 0 ? base64encode(var.opentelemetry_config_file_contents) : value }, { "ECS_SERVICE_NAME" : module.resource_names["ecs_app"].standard })
  map_secrets                  = lookup(each.value, "secrets", null)
  mount_points                 = lookup(each.value, "mount_points", [])
  port_mappings                = lookup(each.value, "port_mappings", [])
  healthcheck                  = lookup(each.value, "healthcheck", null)
  user                         = lookup(each.value, "user", null)
  container_depends_on         = lookup(each.value, "depends_on", [])

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "/ecs/fargate/task/${module.resource_names["ecs_app"].standard}"
      awslogs-region        = var.region
      awslogs-create-group  = "true"
      awslogs-stream-prefix = each.value.name
    }
  }
}

# Security Group for ECS task
module "sg_ecs_service" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.1"

  vpc_id      = var.vpc_id
  name        = module.resource_names["app_ecs_sg"].standard
  description = "Security Group for Application ECS Service"

  ingress_cidr_blocks      = coalesce(try(lookup(var.ecs_security_group, "ingress_cidr_blocks", []), []), [])
  ingress_rules            = coalesce(try(lookup(var.ecs_security_group, "ingress_rules", []), []), [])
  ingress_with_cidr_blocks = coalesce(try(lookup(var.ecs_security_group, "ingress_with_cidr_blocks", []), []), [])
  egress_cidr_blocks       = coalesce(try(lookup(var.ecs_security_group, "egress_cidr_blocks", []), []), [])
  egress_rules             = coalesce(try(lookup(var.ecs_security_group, "egress_rules", []), []), [])
  egress_with_cidr_blocks  = coalesce(try(lookup(var.ecs_security_group, "egress_with_cidr_blocks", []), []), [])

  computed_ingress_with_source_security_group_id = local.ingress_with_sg
  computed_egress_with_source_security_group_id  = local.egress_with_sg

  number_of_computed_ingress_with_source_security_group_id = length(local.ingress_with_sg)
  number_of_computed_egress_with_source_security_group_id  = length(local.egress_with_sg)

  tags = merge(local.tags, { resource_name = module.resource_names["app_ecs_sg"].standard })
}

# ECS Service
module "app_ecs_service" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "~> 0.76.0"

  # This module generates its own name. Can't use the labels module
  namespace                          = "${var.logical_product_family}-${var.logical_product_service}-${join("", split("-", var.region))}"
  stage                              = format("%03d", var.instance_env)
  name                               = var.resource_names_map["ecs_app"].name
  environment                        = var.class_env
  attributes                         = [format("%03d", var.instance_resource)]
  delimiter                          = "-"
  container_definition_json          = jsonencode([for name, container in module.container_definitions : container.json_map_object])
  ecs_cluster_arn                    = var.ecs_cluster_arn
  vpc_id                             = var.vpc_id
  security_group_ids                 = [module.sg_ecs_service.security_group_id]
  security_group_enabled             = false
  subnet_ids                         = var.private_subnets
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  ignore_changes_desired_count       = var.ignore_changes_desired_count
  task_exec_policy_arns_map          = local.task_exec_policy_arns_map
  task_policy_arns_map               = local.task_policy_arns_map
  assign_public_ip                   = var.assign_public_ip
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu
  wait_for_steady_state              = var.wait_for_steady_state
  # Issue: https://github.com/hashicorp/terraform-provider-aws/issues/16674
  force_new_deployment = var.force_new_deployment
  redeploy_on_apply    = var.redeploy_on_apply
  service_registries = [
    {
      registry_arn   = module.sds.arn
      container_name = local.envoy_container.name
    }
  ]
  bind_mount_volumes = var.bind_mount_volumes
  proxy_configuration = {
    type           = "APPMESH"
    container_name = local.envoy_container.name
    properties = {
      AppPorts = join(",", var.app_ports)
      # These values are static and doesn't change for App Mesh. Hence, are hard-coded
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }

  tags = merge(local.tags, { resource_name = module.resource_names["ecs_app"].standard })
}

module "autoscaling_target" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/autoscaling_target/aws"
  version = "~> 1.0"

  count = var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = local.autoscaling_resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(local.tags, { resource_name = module.resource_names["ecs_app"].standard })
}

module "autoscaling_policies" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/autoscaling_policy/aws"
  version = "~> 1.0"

  for_each = var.autoscaling_enabled && length(var.autoscaling_policies) > 0 ? var.autoscaling_policies : {}

  name                   = each.key
  resource_id            = local.autoscaling_resource_id
  scalable_dimension     = "ecs:service:DesiredCount"
  service_namespace      = "ecs"
  predefined_metric_type = each.value.predefined_metric_type
  target_value           = each.value.target_value
  scale_in_cooldown      = each.value.scale_in_cooldown
  scale_out_cooldown     = each.value.scale_out_cooldown

  depends_on = [module.autoscaling_target]
}
