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

locals {

  default_tags = {
    provisioner = "Terraform"
  }

  ingress_with_sg_block = coalesce(try(lookup(var.ecs_security_group, "ingress_with_sg", []), []), [])
  ingress_with_sg = length(local.ingress_with_sg_block) > 0 ? [
    for sg in local.ingress_with_sg_block : {
      from_port                = try(lookup(sg, "port"), 443)
      to_port                  = try(lookup(sg, "port"), 443)
      protocol                 = try(lookup(sg, "protocol"), "tcp")
      source_security_group_id = sg.security_group_id
    }

  ] : []

  egress_with_sg_block = coalesce(try(lookup(var.ecs_security_group, "egress_with_sg", []), []), [])
  egress_with_sg = length(local.egress_with_sg_block) > 0 ? [
    for sg in local.egress_with_sg_block : {
      from_port                = try(lookup(sg, "port"), 443)
      to_port                  = try(lookup(sg, "port"), 443)
      protocol                 = try(lookup(sg, "protocol"), "tcp")
      source_security_group_id = sg.security_group_id
    }

  ] : []

  # Role policies

  task_exec_role_default_managed_policies_map = {
    envoy_access         = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
    ecs_task_exec        = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    envoy_preview_access = "arn:aws:iam::aws:policy/AWSAppMeshPreviewEnvoyAccess"
  }

  task_role_default_managed_policies_map = {
    envoy_access         = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
    ecs_task_exec        = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    envoy_preview_access = "arn:aws:iam::aws:policy/AWSAppMeshPreviewEnvoyAccess"
  }

  task_exec_policy_arns_map = length(var.ecs_exec_role_custom_policy_json) > 0 ? merge(local.task_exec_role_default_managed_policies_map, { custom_policy = module.ecs_task_execution_policy[0].policy_arn }) : local.task_exec_role_default_managed_policies_map
  task_policy_arns_map      = merge(local.task_role_default_managed_policies_map, { custom_policy = module.ecs_task_policy.policy_arn })

  # ACM first domain name must be < 64 characters
  actual_domain_name  = "${module.resource_names["virtual_service"].standard}.${var.namespace_name}"
  updated_domain_name = length(local.actual_domain_name) < 64 ? local.actual_domain_name : "${var.naming_prefix}-vsvc.${var.namespace_name}"
  private_cert_san    = local.actual_domain_name != local.updated_domain_name ? [local.actual_domain_name] : []

  # Health check for app container to evict unhealthy tasks
  app_health_check = length(var.app_health_check_path) > 0 ? merge(var.app_health_check_options,
    {
      command = [
        "CMD-SHELL",
        "curl -s http://localhost:${var.app_ports[0]}${var.app_health_check_path}"
      ]
    }
  ) : null

  # Containers

  envoy_container = {
    # Name is always envoy
    name          = "envoy"
    image_tag     = length(var.envoy_proxy_image) > 0 ? var.envoy_proxy_image : "840364872350.dkr.ecr.us-east-2.amazonaws.com/aws-appmesh-envoy:v1.25.4.0-prod"
    port_mappings = []
    environment = {
      APPMESH_VIRTUAL_NODE_NAME = "mesh/${var.app_mesh_id}/virtualNode/${module.resource_names["virtual_node"].standard}"
    }

    healthcheck = {
      "retries" : 3,
      "command" : [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ]
      "timeout" : 2,
      "interval" : 5,
      "startPeriod" : 60
    }
    # These values are fixed and never changes for envoy proxy
    user                     = "1337"
    memory                   = null
    cpu                      = 0
    memory_reservation       = null
    essential                = true
    readonly_root_filesystem = false
  }

  app_container = {
    # Name is fixed as app. Its used by envoy proxy and ALB.
    name      = "app"
    image_tag = var.app_image_tag
    # Supports multiple application ports
    port_mappings = [for port in var.app_ports : {
      hostPort      = port
      protocol      = "tcp"
      containerPort = port
    }]

    environment              = var.app_environment
    secrets                  = var.app_secrets
    healthcheck              = local.app_health_check
    memory                   = null
    cpu                      = 0
    memory_reservation       = null
    essential                = true
    readonly_root_filesystem = false
    depends_on               = concat(local.app_depends_on_default, var.app_depends_on_extra)
    mount_points             = var.app_mounts
  }

  default_mitm_proxy_environment = {
    UPSTREAM_PORT             = var.app_ports[0]
    UPSTREAM_PROTOCOL         = "http"
    UPSTREAM_HOST             = "localhost"
    LISTEN_PORT               = var.mitm_proxy_ports[0]
    LOG_LEVEL                 = "info"
    HEADER_ENCAPSULATION_MODE = "encode"
  }

  mitm_encoder_container = {
    # Name is fixed as app. Its used by envoy proxy and ALB.
    name      = "encoder"
    image_tag = var.mitm_proxy_image_tag
    # Supports multiple application ports
    port_mappings = [for port in var.mitm_proxy_ports : {
      hostPort      = port
      protocol      = "tcp"
      containerPort = port
    }]

    environment              = merge(local.default_mitm_proxy_environment, var.mitm_proxy_environment)
    secrets                  = var.mitm_proxy_secrets
    memory                   = null
    cpu                      = 0
    memory_reservation       = null
    essential                = true
    readonly_root_filesystem = false
    depends_on               = concat(local.app_depends_on_default, var.app_depends_on_extra)
  }

  default_containers = {
    envoy   = local.envoy_container
    app     = local.app_container
    encoder = local.mitm_encoder_container
  }

  app_depends_on_default = [{
    "containerName" : "envoy",
    "condition" : "HEALTHY"
  }]

  containers = merge(local.default_containers, { for container in var.extra_containers : container.name => container })
  app_mounts = var.app_mounts

  # This policy is required by AppMesh to pull certificates from PCA
  ecs_role_default_policy_json = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PrivateCertAuthorityAccess",
            "Effect": "Allow",
            "Action": [
                "acm-pca:GetCertificateAuthorityCertificate"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "ExportCertificate",
            "Effect": "Allow",
            "Action": [
                "acm:ExportCertificate"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  }
EOF
  # Concat the default policy with optional policies passed in by user as input
  ecs_role_custom_policy_json = length(var.ecs_role_custom_policy_json) > 0 ? [local.ecs_role_default_policy_json, var.ecs_role_custom_policy_json] : [local.ecs_role_default_policy_json]

  ecs_cluster_name        = split("/", var.ecs_cluster_arn)[1]
  autoscaling_resource_id = "service/${local.ecs_cluster_name}/${module.app_ecs_service.service_name}"

  tags = merge(local.default_tags, var.tags)
}
