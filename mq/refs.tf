locals {
  input = {
    "private_d_id" = "/network/subnet/private_d_id"
    "sg_amqp"      = "/network/security_group/amqp_id"
  }

  private_d_id = data.aws_ssm_parameter.inputs["private_d_id"].value
  sg_amqp      = data.aws_ssm_parameter.inputs["sg_amqp"].value
}


data "aws_ssm_parameter" "inputs" {
  for_each = local.input
  name     = each.value
}