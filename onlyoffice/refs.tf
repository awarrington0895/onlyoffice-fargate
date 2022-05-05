locals {
  input = {
    "public_d_id"  = "/network/subnet/public_d_id"
    "public_e_id"  = "/network/subnet/public_e_id"
    "private_d_id" = "/network/subnet/private_d_id"
    "private_e_id" = "/network/subnet/private_e_id"
    "sg_nfs"       = "/network/security_group/nfs_id"
    "sg_http"      = "/network/security_group/http_id"
    "sg_amqp"      = "/network/security_group/amqp_id"
    "sg_https"     = "/network/security_group/https_id"
    "sg_egress"    = "/network/security_group/egress_id"
    "vpc_id"       = "/network/vpc_id"
    "ecr_url"      = "/ecr/repository_url"
  }
}


data "aws_ssm_parameter" "inputs" {
  for_each = local.input
  name = each.value
}