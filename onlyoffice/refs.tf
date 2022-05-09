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
    "onlyoffice_cluster_id" = "/shared/onlyoffice_cluster_id"
  }

  public_d_id  = data.aws_ssm_parameter.inputs["public_d_id"].value
  public_e_id  = data.aws_ssm_parameter.inputs["public_e_id"].value
  private_d_id = data.aws_ssm_parameter.inputs["private_d_id"].value
  private_e_id = data.aws_ssm_parameter.inputs["private_e_id"].value
  sg_nfs       = data.aws_ssm_parameter.inputs["sg_nfs"].value
  sg_http      = data.aws_ssm_parameter.inputs["sg_http"].value
  sg_amqp      = data.aws_ssm_parameter.inputs["sg_amqp"].value
  sg_https     = data.aws_ssm_parameter.inputs["sg_https"].value
  sg_egress    = data.aws_ssm_parameter.inputs["sg_egress"].value
  vpc_id       = data.aws_ssm_parameter.inputs["vpc_id"].value
  ecr_url      = data.aws_ssm_parameter.inputs["ecr_url"].value
  onlyoffice_cluster_id = data.aws_ssm_parameter.inputs["onlyoffice_cluster_id"].value
}


data "aws_ssm_parameter" "inputs" {
  for_each = local.input
  name     = each.value
}