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

output "resource_names" {
  description = "A map of resource_name_types to generated resource names used in this module"
  value       = { for k, v in var.resource_names_map : k => module.resource_names[k].standard }
}

output "ecs_sg_id" {
  description = "The ID of the ECS Security Group"
  value       = module.sg_ecs_service.security_group_id
}

## App Mesh related outputs

output "virtual_node_id" {
  description = "ID of the Virtual Node created for the application"
  value       = module.virtual_node.id
}

output "virtual_service_id" {
  description = "ID of the Virtual Service created for the application"
  value       = module.virtual_service.id
}

output "virtual_node_arn" {
  description = "ARN of the Virtual Node created for the application"
  value       = module.virtual_node.arn
}

output "virtual_service_arn" {
  description = "ARN of the Virtual Service created for the application"
  value       = module.virtual_service.arn
}

output "task_definition_name" {
  description = "Task Definition family of the ECS App"
  value       = module.app_ecs_service.task_definition_family
}

output "task_definition_version" {
  description = "Task Definition revision of the ECS App"
  value       = module.app_ecs_service.task_definition_revision
}

output "task_role_arn" {
  description = "Task Exec role ARN of the ECS App"
  value       = module.app_ecs_service.task_exec_role_arn
}

output "task_exec_role_arn" {
  description = "Task role ARN of the ECS App"
  value       = module.app_ecs_service.task_role_arn
}

output "virtual_gateway_route_arn" {
  description = "ARN of the Virtual Gateway route for the application"
  value       = try(module.gateway_route[0].arn, "")
}

output "virtual_gateway_route_id" {
  description = "ID of the Virtual Gateway route for the application"
  value       = try(module.gateway_route[0].id, "")
}

output "virtual_router_id" {
  description = "ID of the Virtual Router (if enabled)"
  value       = try(module.virtual_router[0].id, "")
}

output "virtual_router_arn" {
  description = "ARN of the Virtual Router (if enabled)"
  value       = try(module.virtual_router[0].arn, "")
}

output "virtual_router_name" {
  description = "Name of the Virtual Router (if enabled)"
  value       = try(module.virtual_router[0].name, "")
}

output "virtual_router_route_arn" {
  description = "ARN of the Virtual Router route (if enabled)"
  value       = try(module.virtual_route[0].arn, "")
}

output "virtual_router_route_id" {
  description = "ID of the Virtual Router route (if enabled)"
  value       = try(module.virtual_route[0].id, "")
}

## ECS related outputs

output "container_json" {
  description = "Container json for the ECS Task Definition"
  value       = var.print_container_json ? [for name, container in module.container_definitions : container.json_map_object] : null
}
