resource "aws_ssm_parameter" "broker_password" {
  name  = "/rabbitmq/broker_password"
  type  = "SecureString"
  value = random_password.broker_password.result
}

resource "aws_ssm_parameter" "broker_connection_uri" {
  name  = "/rabbitmq/broker_connection_uri"
  type  = "SecureString"
  value = "amqp://${local.broker_user}:${random_password.broker_password.result}@${aws_lb.rabbitmq.dns_name}:5672"
}

resource "aws_ssm_parameter" "broker_connection_uri_arn" {
  name  = "/rabbitmq/broker_connection_uri_arn"
  type  = "String"
  value = aws_ssm_parameter.broker_connection_uri.arn
}