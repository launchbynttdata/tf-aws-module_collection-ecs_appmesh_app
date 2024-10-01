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

# output "ecs_sg_id" {
#   description = "The ID of the ECS Security Group"
#   value       = module.sg_ecs_service.security_group_id
# }

# output "virtual_node_id" {
#   description = "ID of the Virtual Node created for the application"
#   value       = module.ecs_example.virtual_node_id
# }

# output "virtual_service_id" {
#   description = "ID of the Virtual Service created for the application"
#   value       = module.ecs_example.virtual_service_id
# }

# output "virtual_node_arn" {
#   description = "ARN of the Virtual Node created for the application"
#   value       = module.ecs_example.virtual_node_arn
# }

# output "virtual_service_arn" {
#   description = "ARN of the Virtual Service created for the application"
#   value       = module.ecs_example.virtual_service_arn
# }

# output "task_definition_name" {
#   description = "Task Definition family of the ECS App"
#   value       = module.ecs_example.task_definition_name
# }

# output "task_definition_version" {
#   description = "Task Definition revision of the ECS App"
#   value       = module.ecs_example.task_definition_version
# }

# output "task_role_arn" {
#   description = "Task Exec role ARN of the ECS App"
#   value       = module.ecs_example.task_role_arn
# }

# output "task_exec_role_arn" {
#   description = "Task role ARN of the ECS App"
#   value       = module.ecs_example.task_exec_role_arn
# }

# output "virtual_gateway_route_arn" {
#   description = "ARN of the Virtual Gateway route for the application"
#   value       = module.ecs_example.virtual_gateway_route_arn
# }

# output "virtual_gateway_route_id" {
#   description = "ID of the Virtual Gateway route for the application"
#   value       = module.ecs_example.virtual_gateway_route_id
# }

# output "virtual_router_id" {
#   description = "ID of the Virtual Router (if enabled)"
#   value       = module.ecs_example.virtual_router_id
# }

# output "virtual_router_arn" {
#   description = "ARN of the Virtual Router (if enabled)"
#   value       = module.ecs_example.virtual_router_arn
# }

# output "virtual_router_name" {
#   description = "Name of the Virtual Router (if enabled)"
#   value       = module.ecs_example.virtual_router_name
# }

# output "virtual_router_route_arn" {
#   description = "ARN of the Virtual Router route (if enabled)"
#   value       = module.ecs_example.virtual_router_route_arn
# }

# output "virtual_router_route_id" {
#   description = "ID of the Virtual Router route (if enabled)"
#   value       = module.ecs_example.virtual_router_route_id
# }

# output "container_json" {
#   description = "Container json for the ECS Task Definition"
#   value       = module.ecs_appmesh_ingress.container_json
# }

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

# output "ecs_cluster_arn" {
#   value = module.ecs_appmesh_platform.ecs_cluster_arn
# }

# output "app_mesh_id" {
#   value = module.ecs_appmesh_platform.app_mesh_id
# }
