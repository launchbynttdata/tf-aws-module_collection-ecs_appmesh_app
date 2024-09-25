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

# VPC Outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_availability_zones" {
  description = "The list of availability zones for the VPC"
  value       = module.vpc.azs
}

output "vpc_default_security_group_id" {
  description = "The ID of the default security group created in the VPC"
  value       = module.vpc.default_security_group_id
}

output "vpc_private_subnet_ids" {
  description = "List of IDs of private subnets created in the VPC"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnet_ids" {
  description = "List of IDs of public subnets created in the VPC (if any)"
  value       = module.vpc.public_subnets
}

output "vpc_nat_gateway_ids" {
  description = "List of NAT Gateway IDs created in the VPC (if any)"
  value       = module.vpc.nat_gateway_ids
}

output "vpc_endpoint_ids" {
  description = "List of VPC Endpoint IDs created in the VPC"
  value       = module.vpc.vpc_endpoints
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = module.ecs_example.ecs_cluster_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS Cluster"
  value       = module.ecs_example.ecs_cluster_arn
}

output "ecs_service_id" {
  description = "The ID of the ECS Service"
  value       = module.ecs_example.ecs_service_id
}

output "ecs_service_name" {
  description = "The name of the ECS Service"
  value       = module.ecs_example.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS Task Definition"
  value       = module.ecs_example.task_definition_arn
}

output "ecs_security_group_id" {
  description = "The security group ID associated with the ECS service"
  value       = module.ecs_example.ecs_security_group_id
}

output "ecs_service_desired_count" {
  description = "The desired count of the ECS service tasks"
  value       = module.ecs_example.desired_count
}

output "ecs_service_task_definition" {
  description = "The task definition used by the ECS service"
  value       = module.ecs_example.task_definition_family
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS Task Execution Role"
  value       = module.ecs_example.task_exec_role_arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS Task Role"
  value       = module.ecs_example.task_role_arn
}

output "ecs_log_group" {
  description = "The name of the log group for ECS tasks"
  value       = module.ecs_example.log_group_name
}

# App Mesh Outputs
output "app_mesh_id" {
  description = "The ID of the App Mesh"
  value       = module.ecs_example.app_mesh_id
}

output "app_mesh_virtual_node_id" {
  description = "The ID of the App Mesh Virtual Node"
  value       = module.ecs_example.virtual_node_id
}

output "app_mesh_virtual_node_arn" {
  description = "The ARN of the App Mesh Virtual Node"
  value       = module.ecs_example.virtual_node_arn
}

output "app_mesh_virtual_service_id" {
  description = "The ID of the App Mesh Virtual Service"
  value       = module.ecs_example.virtual_service_id
}

output "app_mesh_virtual_service_arn" {
  description = "The ARN of the App Mesh Virtual Service"
  value       = module.ecs_example.virtual_service_arn
}

output "app_mesh_virtual_gateway_route_id" {
  description = "The ID of the App Mesh Virtual Gateway Route"
  value       = try(module.ecs_example.virtual_gateway_route_id, "")
}

output "app_mesh_virtual_gateway_route_arn" {
  description = "The ARN of the App Mesh Virtual Gateway Route"
  value       = try(module.ecs_example.virtual_gateway_route_arn, "")
}

output "app_mesh_virtual_router_id" {
  description = "The ID of the Virtual Router in App Mesh"
  value       = try(module.ecs_example.virtual_router_id, "")
}

output "app_mesh_virtual_router_arn" {
  description = "The ARN of the Virtual Router in App Mesh"
  value       = try(module.ecs_example.virtual_router_arn, "")
}

output "app_mesh_virtual_router_name" {
  description = "The name of the Virtual Router in App Mesh"
  value       = try(module.ecs_example.virtual_router_name, "")
}

output "app_mesh_virtual_router_route_id" {
  description = "The ID of the Virtual Router route"
  value       = try(module.ecs_example.virtual_router_route_id, "")
}

output "app_mesh_virtual_router_route_arn" {
  description = "The ARN of the Virtual Router route"
  value       = try(module.ecs_example.virtual_router_route_arn, "")
}

# VPC Security Groups Outputs
output "vpc_endpoint_security_group_id" {
  description = "The security group ID attached to the VPC endpoints"
  value       = module.vpc.vpce_security_group_id
}

# Autoscaling Outputs (if applicable)
output "ecs_autoscaling_target_arn" {
  description = "The ARN of the autoscaling target for ECS service"
  value       = try(module.ecs_example.autoscaling_target_arn, "")
}

output "ecs_autoscaling_policy_arns" {
  description = "The ARNs of the autoscaling policies for ECS service"
  value       = try([for policy in module.ecs_example.autoscaling_policies : policy.arn], [])
}

# General Tags Output
output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}
