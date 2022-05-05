locals {
  input = {
    "private_d_id" = "/network/subnet/private_d_id"
    "sg_amqp"      = "/network/security_group/amqp_id"
    "sg_egress"    = "/network/security_group/egress_id"
    "vpc_id"       = "/network/vpc_id"
    "ecr_url"      = "/ecr/repository_url"
  }
}


data "aws_ssm_parameter" "inputs" {
  for_each = local.input
  name = each.value
}