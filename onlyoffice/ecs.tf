resource "aws_cloudwatch_log_group" "onlyoffice_logs" {
  name = "/ecs/onlyoffice"
}

resource "aws_ecs_cluster" "app" {
  name = "app"
}

resource "aws_ecs_task_definition" "onlyoffice" {
  family                   = "onlyoffice"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.onlyoffice_task_execution_role.arn
  task_role_arn            = aws_iam_role.onlyoffice_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "onlyoffice"
      image        = "${data.aws_ssm_parameter.inputs["ecr_url"].value}:latest"
      cpu          = 2048
      memory       = 4096
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      environment = [
        {
          name  = "AMQP_URI"
          value = "amqps://${var.amqp_username}:${var.amqp_password}@${var.amqp_host}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region        = "us-east-1"
          awslogs-group         = "/ecs/onlyoffice"
          awslogs-stream-prefix = "ecs"
        }
      }

      mountPoints = [
        {
          sourceVolume  = "onlyoffice-files"
          containerPath = "/var/lib/onlyoffice"
        },
        {
          sourceVolume  = "onlyoffice-logs"
          containerPath = "/var/log/onlyoffice"
        },
        {
          sourceVolume  = "rabbitmq"
          containerPath = "/var/lib/rabbitmq"
        }
      ]
    }
  ])

  volume {
    name = "onlyoffice-logs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.onlyoffice.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.onlyoffice-logs.id
      }
    }
  }

  volume {
    name = "onlyoffice-files"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.onlyoffice.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.onlyoffice-files.id
      }
    }
  }

  volume {
    name = "rabbitmq"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.onlyoffice.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.rabbitmq.id
      }
    }
  }
}

resource "aws_ecs_service" "onlyoffice" {
  name            = "onlyoffice"
  task_definition = aws_ecs_task_definition.onlyoffice.arn
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  desired_count   = 1
  #  enable_execute_command = true

  network_configuration {
    assign_public_ip = false

    security_groups = [
      data.aws_ssm_parameter.inputs["sg_egress"].value,
      data.aws_ssm_parameter.inputs["sg_http"].value,
      data.aws_ssm_parameter.inputs["sg_nfs"].value
    ]

    subnets = [
      data.aws_ssm_parameter.inputs["private_d_id"].value,
      data.aws_ssm_parameter.inputs["private_e_id"].value
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.onlyoffice.arn
    container_name   = "onlyoffice"
    container_port   = 80
  }
}

resource "aws_alb" "onlyoffice" {
  name               = "onlyoffice-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    data.aws_ssm_parameter.inputs["public_d_id"].value,
    data.aws_ssm_parameter.inputs["public_e_id"].value,
  ]

  security_groups = [
    data.aws_ssm_parameter.inputs["sg_http"].value,
    data.aws_ssm_parameter.inputs["sg_https"].value,
    data.aws_ssm_parameter.inputs["sg_egress"].value
  ]
}

resource "aws_alb_listener" "onlyoffice_http" {
  load_balancer_arn = aws_alb.onlyoffice.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.onlyoffice.arn
  }
}

resource "aws_lb_target_group" "onlyoffice" {
  name        = "onlyoffice"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_ssm_parameter.inputs["vpc_id"].value

  health_check {
    enabled           = true
    protocol          = "HTTP"
    path              = "/"
    timeout           = 120
    interval          = 180
    matcher           = "200,302"
    healthy_threshold = 2
  }

  depends_on = [aws_alb.onlyoffice]
}

output "alb_url" {
  value = "http://${aws_alb.onlyoffice.dns_name}"
}
