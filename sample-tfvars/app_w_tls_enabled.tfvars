logical_product_family  = "launch"
logical_product_service = "java"
instance_env            = 0
class_env               = "sandbox"

vpc_id = "<vpc-id>"
private_subnets = [
  "<private-subnet-ids>"
]

namespace_name  = "<cloud-map-ns-name>"
namespace_id    = "<cloud-map-ns-id>"
ecs_cluster_arn = "<ecs-cluster-arn>"
app_mesh_id     = "<app-mesh-name/id>"
# If this is in another account, then IAM policy must be assigned to the PCA to allow access from this account
private_ca_arn = "<private-ca-arn>"
# From the ingress module
virtual_gateway_name = "<virtual-gateway-name>"
# Port at which the app listens in the docker container
app_ports = ["<app-port>"]
# if public image path is provided, NAT gateway is required to pull image
app_image_tag = "<docker-image-with-tag>"
# docker based health check
app_health_check_path              = "<health-check-path>"
virtual_node_app_health_check_path = "<health-check-path>"

# Must allow ingress on app port
ecs_security_group = {
  ingress_rules       = ["http-8080-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

force_new_deployment           = true
redeploy_on_apply              = true
ignore_changes_desired_count   = false
ignore_changes_task_definition = false
wait_for_steady_state          = false

desired_count = 1

# This is the path at this the application can be accessed on the ingress url
match_path_prefix = "<context-root-in-ingress-url>"

tags = {
  "Owner" = "DSO Team"
}
