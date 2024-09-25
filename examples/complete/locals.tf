locals {
  random_id               = random_integer.priority.result # Assuming random_integer is already defined elsewhere
  logical_product_service = "${var.logical_product_service}${local.random_id}"
  naming_prefix           = "${var.logical_product_family}-${local.logical_product_service}"
  vpc_name                = "${local.naming_prefix}-vpc"
  namespace_name          = "${local.naming_prefix}.local"
}
