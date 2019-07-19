provider "aws" {
  alias   = "inst"
  region  = "${var.region}"
  version = "~> 2.17"
}

module "network" {
  source = "../../modules/network"

  providers = {
    "aws" = "aws.inst"
  }

  platform_name      = "${var.platform_name}"
  availability_zones = "${var.availability_zones}"
  platform_cidr      = "${var.platform_cidr}"
}

module "infra" {
  source = "../../modules/infra"

  providers = {
    "aws" = "aws.inst"
  }

  platform_name = "${var.platform_name}"
  use_community = "${var.use_community}"

  platform_vpc_id    = "${module.network.platform_vpc_id}"
  public_subnet_ids  = ["${module.network.public_subnet_ids}"]
  private_subnet_ids = ["${module.network.private_subnet_ids}"]

  operator_cidrs = ["${var.operator_cidrs}"]
  public_cidrs   = ["${var.public_cidrs}"]

  use_spot = "${var.use_spot}"

  master_count               = "${var.master_count}"
  master_instance_type       = "${var.master_instance_type}"
  compute_node_count         = "${var.compute_node_count}"
  compute_node_instance_type = "${var.compute_node_instance_type}"
}

module "openshift" {
  source = "../../modules/openshift"

  providers = {
    "aws" = "aws.inst"
  }

  platform_name = "${var.platform_name}"
  use_community = "${var.use_community}"

  bastion_ssh_user        = "${module.infra.bastion_ssh_user}"
  bastion_endpoint        = "${module.infra.bastion_endpoint}"
  platform_private_key    = "${module.infra.platform_private_key}"
  rhn_username            = "${var.rhn_username}"
  rhn_password            = "${var.rhn_password}"
  rh_subscription_pool_id = "${var.rh_subscription_pool_id}"

  master_domain                       = "${module.infra.master_domain}"
  platform_domain                     = "${var.platform_domain}"
  public_certificate_pem              = "${var.public_certificate_pem}"
  public_certificate_key              = "${var.public_certificate_key}"
  public_certificate_intermediate_pem = "${var.public_certificate_intermediate_pem}"

  identity_providers = "${var.identity_providers}"
}
