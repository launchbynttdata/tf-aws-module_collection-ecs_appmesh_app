locals {
  vpc_name                = "vpc"
  logical_product_service = "int-ing"
  ecs_appmesh_app_name    = "${var.logical_product_service}-${var.class_env}-app"
  ecs_security_group_name = "${var.logical_product_service}-${var.class_env}-sg"
  virtual_gateway_name    = "${var.logical_product_service}-${var.class_env}-gateway"
  namespace_name          = "${var.logical_product_service}-${var.class_env}-namespace"
  ecs_cluster_name        = "${var.logical_product_service}-${var.class_env}-cluster"
  
}
