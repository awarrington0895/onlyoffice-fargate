resource "aws_mq_broker" "main" {
  broker_name         = "onlyoffice-broker"
  engine_type         = "RabbitMQ"
  engine_version      = "3.9.13"
  host_instance_type  = "mq.t3.micro"
  deployment_mode     = "SINGLE_INSTANCE"
  publicly_accessible = false

  security_groups = [
    local.sg_amqp
  ]

  subnet_ids = [
    local.private_d_id
  ]

  logs {
    general = true
  }

  user {
    password = var.password
    username = var.username
  }

}