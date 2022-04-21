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

data "aws_iam_policy" "efs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_role" "onlyoffice_task_execution_role" {
  name               = "onlyoffice-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_iam_role_policy_attachment" "efs_full_access" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.efs_full_access.arn
}

resource "aws_ecs_cluster" "app" {
  name = "app"
}

resource "aws_efs_file_system" "onlyoffice" {
  creation_token = "onlyoffice-volume"
}

resource "aws_efs_access_point" "onlyoffice-ap" {
  file_system_id = aws_efs_file_system.onlyoffice.id
}

resource "aws_efs_access_point" "onlyoffice-logs" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
    path = "/onlyoffice/logs"
  }
}

resource "aws_efs_access_point" "onlyoffice-files" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
    path = "/onlyoffice/files"
  }
}

resource "aws_efs_access_point" "rabbitmq" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }

    path = "/rabbitmq"
  }
}

resource "aws_efs_mount_target" "pub1e" {
  file_system_id  = aws_efs_file_system.onlyoffice.id
  subnet_id       = aws_subnet.public_e.id
  security_groups = [
    aws_security_group.nfs.id
  ]
}

resource "aws_efs_mount_target" "pub1d" {
  file_system_id  = aws_efs_file_system.onlyoffice.id
  subnet_id       = aws_subnet.public_d.id
  security_groups = [
    aws_security_group.nfs.id
  ]
}

resource "aws_ecs_task_definition" "onlyoffice" {
  family                   = "onlyoffice"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.onlyoffice_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = "onlyoffice"
      image        = "${aws_ecr_repository.onlyoffice.repository_url}:latest"
      #      image        = "onlyoffice/documentserver-de:7.0.1"
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
          sourceVolume = "rabbitmq"
          containerPath = "/var/lib/rabbitmq"
        }
      ]
    }
  ])

  volume {
    name = "onlyoffice-logs"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.onlyoffice.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.onlyoffice-logs.id
      }
    }
  }

  volume {
    name = "onlyoffice-files"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.onlyoffice.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.onlyoffice-files.id
      }
    }
  }

  volume {
    name = "rabbitmq"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.onlyoffice.id
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

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.http.id,
      aws_security_group.nfs.id
    ]

    subnets = [
      aws_subnet.private_d.id,
      aws_subnet.private_e.id
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
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/"
    timeout  = 120
    interval = 180
    matcher  = "200,302"
    healthy_threshold = 2
  }

  depends_on = [aws_alb.onlyoffice]
}

resource "aws_ecr_repository" "onlyoffice" {
  name = "onlyoffice"
}

output "alb_url" {
  value = "http://${aws_alb.onlyoffice.dns_name}"
}
