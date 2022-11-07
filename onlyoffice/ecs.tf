resource "aws_cloudwatch_log_group" "demo_logs" {
  name = "/ecs/demo"
}

resource "aws_ecs_task_definition" "demo" {
  family                   = "demo"
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.onlyoffice_task_execution_role.arn
  task_role_arn            = aws_iam_role.onlyoffice_task_role.arn

  container_definitions = jsonencode([
    {
      name   = "demo"
      image  = "${local.ecr_url}:latest"
      cpu    = 2048
      memory = 4096
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "us-east-1"
          awslogs-group         = "/ecs/demo"
          awslogs-stream-prefix = "ecs"
        }
      }

      mountPoints = [
        {
          sourceVolume  = "logs"
          containerPath = "/logs"
        }
      ]
    },
    {
      name = "cloudwatch-agent"
      image = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest"
      secrets = [
        {
          name = "CW_CONFIG_CONTENT"
          valueFrom = "ecs-cwagent"
        }
      ]

      mountPoints = [
        {
          sourceVolume = "logs"
          containerPath = "/logs"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group = "True"
          awslogs-group = "/ecs/ecs-cwagent-fargate"
          awslogs-region = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "logs"
  }
}

resource "aws_ecs_service" "demo" {
  name            = "demo"
  task_definition = aws_ecs_task_definition.demo.arn
  cluster         = local.onlyoffice_cluster_id
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = false

    security_groups = [
      local.sg_egress,
      local.sg_http,
      local.sg_nfs
    ]

    subnets = [
      local.private_d_id,
      local.private_e_id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo.arn
    container_name   = "demo"
    container_port   = 8080
  }
}

resource "aws_alb" "demo" {
  name               = "demo-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    local.public_d_id,
    local.public_e_id
  ]

  security_groups = [
    local.sg_http,
    local.sg_https,
    local.sg_egress
  ]
}

resource "aws_alb_listener" "onlyoffice_http" {
  load_balancer_arn = aws_alb.demo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo.arn
  }
}

resource "aws_lb_target_group" "demo" {
  name        = "demo"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    enabled           = true
    protocol          = "HTTP"
    path              = "/hello"
    timeout           = 120
    interval          = 180
    matcher           = "200,302"
    healthy_threshold = 2
  }

  depends_on = [aws_alb.demo]
}

output "alb_url" {
  value = "http://${aws_alb.demo.dns_name}"
}
