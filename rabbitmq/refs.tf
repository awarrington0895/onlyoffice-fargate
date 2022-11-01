locals {
  input = {
    "onlyoffice_cluster_id" = "/shared/demo_cluster_id"
    "sg_amqp"               = "/network/security_group/amqp_id"
    "sg_egress"             = "/network/security_group/egress_id"
    "private_e_id"          = "/network/subnet/private_e_id"
    "vpc_id"                = "/network/vpc_id"
    "allow_ssm_secrets_arn" = "/shared/iam/allow_ssm_secrets_arn"
  }

  onlyoffice_cluster_id = data.aws_ssm_parameter.inputs["onlyoffice_cluster_id"].value
  sg_amqp               = data.aws_ssm_parameter.inputs["sg_amqp"].value
  sg_egress             = data.aws_ssm_parameter.inputs["sg_egress"].value
  private_e_id          = data.aws_ssm_parameter.inputs["private_e_id"].value
  vpc_id                = data.aws_ssm_parameter.inputs["vpc_id"].value
  allow_ssm_secrets_arn = data.aws_ssm_parameter.inputs["allow_ssm_secrets_arn"].value
}


data "aws_ssm_parameter" "inputs" {
  for_each = local.input
  name     = each.value
}
