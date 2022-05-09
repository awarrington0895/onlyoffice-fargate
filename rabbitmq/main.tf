locals {
  log_path    = "/ecs/rabbitmq"
  broker_user = "onlyoffice"
}

resource "aws_iam_role_policy_attachment" "allow_ssm_secrets" {
  role       = aws_iam_role.rabbitmq_task_execution_role.name
  policy_arn = local.allow_ssm_secrets_arn
}

resource "random_password" "broker_password" {
  length  = 16
  special = false
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "rabbitmq_task_execution_role" {
  name               = "rabbitmq-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.rabbitmq_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_cloudwatch_log_group" "rabbitmq_logs" {
  name = local.log_path
}

resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "rabbitmq"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.rabbitmq_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name   = "rabbitmq"
      image  = "rabbitmq:3"
      cpu    = 2048
      memory = 4096
      portMappings = [
        {
          containerPort = 5672
          hostPort      = 5672
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "RABBITMQ_DEFAULT_USER"
          value = local.broker_user
        }
      ]

      secrets = [
        {
          name      = "RABBITMQ_DEFAULT_PASS"
          valueFrom = aws_ssm_parameter.broker_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "us-east-1"
          awslogs-group         = local.log_path
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "rabbitmq" {
  name            = "rabbitmq"
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  cluster         = local.onlyoffice_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = false

    security_groups = [
      local.sg_amqp,
      local.sg_egress
    ]

    subnets = [
      local.private_e_id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rabbitmq.arn
    container_name   = "rabbitmq"
    container_port   = 5672
  }

  depends_on = [aws_lb_target_group.rabbitmq]
}

resource "aws_lb" "rabbitmq" {
  name               = "rabbitmq-network-lb"
  internal           = true
  load_balancer_type = "network"

  subnets = [
    local.private_e_id
  ]

  tags = {
    Name = "RabbitMQ Load Balancer"
  }
}

resource "aws_lb_target_group" "rabbitmq" {
  name        = "onlyoffice-rabbitmq-lb-tg"
  port        = 5672
  protocol    = "TCP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  stickiness {
    type    = "source_ip"
    enabled = false
  }

  depends_on = [aws_lb.rabbitmq]
}

resource "aws_lb_listener" "rabbitmq" {
  load_balancer_arn = aws_lb.rabbitmq.arn
  port              = 5672
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rabbitmq.arn
  }
}

output "nlb_url" {
  value = "http://${aws_lb.rabbitmq.dns_name}"
}