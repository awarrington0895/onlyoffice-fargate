resource "aws_cloudwatch_log_group" "onlyoffice_logs" {
  name = "/ecs/onlyoffice"
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

resource "aws_iam_role" "onlyoffice_task_execution_role" {
  name               = "onlyoffice-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_ecs_cluster" "app" {
  name = "app"
}

resource "aws_ecs_task_definition" "onlyoffice" {
  family                   = "onlyoffice"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.onlyoffice_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = "onlyoffice"
      image        = "${aws_ecr_repository.onlyoffice.repository_url}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
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
    }
  ])
}

resource "aws_ecs_service" "onlyoffice" {
  name            = "onlyoffice"
  task_definition = aws_ecs_task_definition.onlyoffice.arn
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  desired_count = 1

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.http.id
    ]

    subnets = [
      aws_subnet.private_d.id,
      aws_subnet.private_e.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.onlyoffice.arn
    container_name = "onlyoffice"
    container_port = 80
  }
}

resource "aws_alb" "onlyoffice" {
  name = "onlyoffice-lb"
  internal = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_d.id,
    aws_subnet.public_e.id
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress_all.id
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "onlyoffice_http" {
  load_balancer_arn = aws_alb.onlyoffice.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.onlyoffice.arn
  }
}

resource "aws_lb_target_group" "onlyoffice" {
  name = "onlyoffice"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    protocol = "HTTP"
    path = "/"
    timeout = 120
    interval = 300
    matcher = "200,302"

  }

  depends_on = [aws_alb.onlyoffice]
}

resource "aws_ecr_repository" "onlyoffice" {
  name = "onlyoffice"
}

output "alb_url" {
  value = "http://${aws_alb.onlyoffice.dns_name}"
}
