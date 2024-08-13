# Need to fill the properties within <> like, private_ca_arn, app_image_tag, app_port, namespace_name, namespace_id,
# app_mesh_id, ecs_cluster_arn
# These above variables are made required so that the user must enter those
#
# In the case of *.ingress_cidr_blocks, see var.vpc_cidr default value (or override it below with that of the existing
# VPC you have selected) then duplicate it into both SGs' ingress_cidr_blocks

#These two var values should refer to the same resource
namespace_name = "sandbox.launch.nttdata.com"
namespace_id   = "ns-c7lazkvdal7jroz6"

app_mesh_id = "arn:aws:appmesh:us-east-2:020127659860:mesh/for_ecs_appmesh_app"

ecs_cluster_arn = "arn:aws:ecs:us-east-2:020127659860:cluster/vpn-poc-fargate-cluster1"

interface_vpc_endpoints = {
  ecrdkr = {
    service_name        = "ecr.dkr"
    private_dns_enabled = true
  }
  ecrapi = {
    service_name        = "ecr.api"
    private_dns_enabled = true
  }
  ecs = {
    service_name        = "ecs"
    private_dns_enabled = true
  }
  logs = {
    service_name        = "logs"
    private_dns_enabled = true
  }
  appmesh = {
    service_name        = "appmesh"
    private_dns_enabled = true
  }
}

gateway_vpc_endpoints = {
  s3 = {
    service_name        = "s3"
    private_dns_enabled = true
  }
}

vpce_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["172.55.0.0/16"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

force_new_deployment = true

private_ca_arn = "arn:aws:acm-pca:us-east-2:020127659860:certificate-authority/aae3aa9a-a2d0-42ac-a16b-0fc6d54b109c"

app_image_tag = "public.ecr.aws/nginx/nginx:latest"
app_port      = 8080

app_security_group = {
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  ingress_cidr_blocks = ["172.55.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      from_port = 8080
      to_port   = 8080
      protocol  = "tcp"
    }
  ]
}
