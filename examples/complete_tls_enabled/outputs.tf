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

output "app_mesh_id" {
  value = module.ecs_platform.app_mesh_id
}

output "namespace_id" {
  value = module.ecs_platform.namespace_id
}

output "namespace_name" {
  value = module.ecs_platform.namespace_name
}

output "private_ca_arn" {
  value = var.private_ca_arn
}

output "virtual_gateway_name" {
  value = module.ecs_ingress.virtual_gateway_name
}

output "virtual_node_id" {
  value = module.ecs_appmesh_app.virtual_node_id
}

output "virtual_service_id" {
  value = module.ecs_appmesh_app.virtual_service_id
}

output "virtual_router_id" {
  value = module.ecs_appmesh_app.virtual_router_id
}

output "virtual_gateway_route_id" {
  value = module.ecs_appmesh_app.virtual_gateway_route_id
}

output "ecs_sg_id" {
  value = module.ecs_appmesh_app.ecs_sg_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
