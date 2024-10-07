# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //     http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.

## vpc related outputs

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

## App Mesh related outputs

output "virtual_node_id" {
  description = "ID of the Virtual Node created for the application"
  value       = module.ecs_appmesh_app.virtual_node_id
}

output "virtual_service_id" {
  description = "ID of the Virtual Service created for the application"
  value       = module.ecs_appmesh_app.virtual_service_id
}

output "virtual_node_arn" {
  description = "ARN of the Virtual Node created for the application"
  value       = module.ecs_appmesh_app.virtual_node_arn
}

output "virtual_service_arn" {
  description = "ARN of the Virtual Service created for the application"
  value       = module.ecs_appmesh_app.virtual_service_arn
}

output "task_definition_name" {
  description = "Task Definition family of the ECS App"
  value       = module.ecs_appmesh_app.task_definition_name
}

output "task_definition_version" {
  description = "Task Definition revision of the ECS App"
  value       = module.ecs_appmesh_app.task_definition_version
}

output "task_role_arn" {
  description = "Task Exec role ARN of the ECS App"
  value       = module.ecs_appmesh_app.task_role_arn
}

output "task_exec_role_arn" {
  description = "Task role ARN of the ECS App"
  value       = module.ecs_appmesh_app.task_exec_role_arn
}

output "virtual_gateway_route_arn" {
  description = "ARN of the Virtual Gateway route for the application"
  value       = module.ecs_appmesh_app.virtual_gateway_route_arn
}

output "virtual_gateway_route_id" {
  description = "ID of the Virtual Gateway route for the application"
  value       = module.ecs_appmesh_app.virtual_gateway_route_id
}

output "virtual_router_id" {
  description = "ID of the Virtual Router (if enabled)"
  value       = module.ecs_appmesh_app.virtual_router_id
}

output "virtual_router_arn" {
  description = "ARN of the Virtual Router (if enabled)"
  value       = module.ecs_appmesh_app.virtual_router_arn
}

output "virtual_router_name" {
  description = "Name of the Virtual Router (if enabled)"
  value       = module.ecs_appmesh_app.virtual_router_name
}

output "virtual_router_route_arn" {
  description = "ARN of the Virtual Router route (if enabled)"
  value       = module.ecs_appmesh_app.virtual_router_route_arn
}

output "virtual_router_route_id" {
  description = "ID of the Virtual Router route (if enabled)"
  value       = module.ecs_appmesh_app.virtual_router_route_id
}

output "container_json" {
  description = "Container json for the ECS Task Definition"
  value       = module.ecs_appmesh_app.container_json
}

# ecs_platform related outputs
output "namespace_name" {
  value = module.ecs_platform.namespace_name
}

output "namespace_id" {
  description = "ID of the Cloud Map Namespace"
  value       = module.ecs_platform.namespace_id
}

output "namespace_arn" {
  description = "ARN of the Cloud Map Namespace"
  value       = module.ecs_platform.namespace_arn
}

output "namespace_hosted_zone" {
  description = "Hosted Zone of Cloud Map Namespace"
  value       = module.ecs_platform.namespace_hosted_zone
}

output "app_mesh_id" {
  description = "ID of the App Mesh"
  value       = module.ecs_platform.app_mesh_id
}

output "app_mesh_arn" {
  description = "ARN of the App Mesh"
  value       = module.ecs_platform.app_mesh_arn
}

output "fargate_arn" {
  description = "The ARN of the ECS fargate cluster"
  value       = module.ecs_platform.fargate_arn
}

# # #ingress related outputs

output "alb_arn" {
  value = module.ecs_ingress.alb_arn
}
output "alb_cert_arn" {
  value = module.ecs_ingress.alb_cert_arn
}
output "alb_dns" {
  value = module.ecs_ingress.alb_dns
}
output "alb_id" {
  value = module.ecs_ingress.alb_id
}
output "dns_zone_id" {
  value = module.ecs_ingress.dns_zone_id
}
output "dns_zone_name" {
  value = module.ecs_ingress.dns_zone_name
}
output "private_ca_arn" {
  value = module.ecs_ingress.private_ca_arn
}
output "virtual_gateway_arn" {
  value = module.ecs_ingress.virtual_gateway_arn
}
output "virtual_gateway_cert_arn" {
  value = module.ecs_ingress.virtual_gateway_cert_arn
}
output "virtual_gateway_name" {
  value = module.ecs_ingress.virtual_gateway_name
}

