locals {
  vpc_name                = "vpc"
  ecs_appmesh_app_name    = "${var.logical_product_service}-${var.class_env}-app"
  ecs_security_group_name = "${var.logical_product_service}-${var.class_env}-sg"
  virtual_gateway_name    = "${var.logical_product_service}-${var.class_env}-gateway"
  namespace_name          = "${var.logical_product_service}-${var.class_env}-namespace"
  ecs_cluster_name        = "${var.logical_product_service}-${var.class_env}-cluster"
  logical_product_service = var.logical_product_service

  alb_sg = {
  description         = "Security group for ALB"
  ingress_cidr_blocks = ["10.1.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    },
    {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

  # Additional locals for better readability
  # environment               = var.class_env
  # app_image                 = var.app_image_tag
  # app_ports                 = var.app_ports
  # desired_count             = var.desired_count
  # health_check_path         = var.app_health_check_path
  # virtual_node_health_check = var.virtual_node_app_health_check_path

  # Security group configuration
  # ingress_rules       = var.ecs_security_group.ingress_rules
  # ingress_cidr_blocks = var.ecs_security_group.ingress_cidr_blocks
  # egress_rules        = var.ecs_security_group.egress_rules
  # egress_cidr_blocks  = var.ecs_security_group.egress_cidr_blocks
}
