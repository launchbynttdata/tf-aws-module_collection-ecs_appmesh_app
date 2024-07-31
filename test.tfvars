# Ensure you have a profile by this name in your ~/.aws/config file
aws_profile = "launch-sandbox-admin"

app_mesh_id = "tests_appmesh1-999"

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
