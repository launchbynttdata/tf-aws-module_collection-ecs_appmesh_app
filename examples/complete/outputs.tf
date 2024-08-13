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

output "virtual_gateway_name" {
  description = "Name of the Virtual gateway in which gateway route will be created"
  value       = module.virtual_gateway.name
}

output "app_mesh_id" {
  description = "Id/Arn of the App Mesh"
  value       = var.app_mesh_id
}

output "app_mesh_name" {
  description = "Name of the App Mesh"
  value       = local.app_mesh_name
}
