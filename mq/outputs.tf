locals {
  uri_no_protocol = split("//", aws_mq_broker.main.instances.0.endpoints.0)[1]
  broker_uri      = split(":", local.uri_no_protocol)[0]
}

resource "aws_ssm_parameter" "broker_connection_uri" {
  name  = "/mq/broker_connection_uri"
  type  = "SecureString"
  value = "amqps://${local.broker_user}:${local.broker_password}@${local.broker_uri}:5671"
}

resource "aws_ssm_parameter" "broker_connection_uri_arn" {
  name  = "/mq/broker_connection_uri_arn"
  type  = "String"
  value = aws_ssm_parameter.broker_connection_uri.arn
}