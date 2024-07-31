# Ensure you have a profile by this name in your ~/.aws/config file
aws_profile = "launch-sandbox-admin"

# From a make check of tf-aws-module_primitive-private_ca with teardown skipped
private_ca_arn = "arn:aws:acm-pca:us-east-2:020127659860:certificate-authority/6aafc361-7ede-4863-8a1a-0ab9b1c3283a"

# From a terraform apply of tf-aws-module_primitive-virtual_gateway/examples/with_tls_enforced plan
virtual_gateway_name = "terratest-vgwtest-vgw-39104"
app_mesh_id          = "terratest-vgwtest-app-mesh-39104"

# From a terraform apply of tf-aws-module_primitive-service_discovery_service/examples/complete plan
vpc_id          = "vpc-0a4db369a13eed749"
namespace_id    = "ns-s2rpytrvyepthdpo"
namespace_name  = "example75300.local"
private_subnets = ["subnet-05c8f3d86226e4f70", "subnet-087911651a1d81207", "subnet-03b332d585c1f4485"]

# From fargate via VPN testing prior to app deployment
ecs_cluster_arn = "arn:aws:ecs:us-east-2:020127659860:cluster/vpn-poc-fargate-cluster1"

# MITM
mitm_proxy_ports     = ["123", "456"]
mitm_proxy_image_tag = "public.ecr.aws/nginx/nginx:latest"

app_image_tag = "public.ecr.aws/nginx/nginx:latest"

resource_names_map = {
  app_ecs_sg = {
    name       = "appsg"
    max_length = 60
  }
  virtual_service = {
    name       = "vsvc"
    max_length = 60
  }
  virtual_node = {
    name       = "vnode"
    max_length = 60
  }
  virtual_router = {
    name       = "vrouter"
    max_length = 60
  }
  router_route = {
    name       = "vroute"
    max_length = 60
  }
  gateway_route = {
    name       = "gwroute"
    max_length = 60
  }
  acm = {
    name       = "acm"
    max_length = 60
  }
  service_discovery_service = {
    # should be same as the service discovery service used in the ECS service
    name       = "vsvc"
    max_length = 60
  }
  task_exec_role = {
    name       = "execrole"
    max_length = 60
  }
  task_role = {
    name       = "taskrole"
    max_length = 60
  }
  task_exec_policy = {
    name       = "execplcy"
    max_length = 60
  }
  task_policy = {
    name       = "taskplcy"
    max_length = 60
  }
  ecs_app = {
    name       = "svc"
    max_length = 60
  }
  ecs_td = {
    name       = "td"
    max_length = 60
  }
}

containers = [
  {
    name = "backend"
    # image_tag will be injected in locals.tf
    # image_tag = ""
    log_configuration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/fargate/task/demo-app-server"
        awslogs-region        = "us-east-2"
        awslogs-create-group  = "true"
        awslogs-stream-prefix = "demoapp"
      }
    }
    environment = {
      FLASK_RUN_PORT = "8081"
    }
    port_mappings = [{
      # port mappings should also change in target group and ecs security group
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }
]

tags = {
  Purpose = "terratest examples"
  Env     = "sandbox"
  Team    = "platform-engineering"
}
