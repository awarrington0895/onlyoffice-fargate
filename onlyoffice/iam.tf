data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    effect  = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec" {
  name        = "allow-ecs-exec"
  path        = "/"
  description = "Allows ecs services to enable ecs exec"
  policy      = data.aws_iam_policy_document.ecs_exec.json
  #  policy = <<EOF
  #  {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #       {
  #       "Effect": "Allow",
  #       "Action": [
  #            "ssmmessages:CreateControlChannel",
  #            "ssmmessages:CreateDataChannel",
  #            "ssmmessages:OpenControlChannel",
  #            "ssmmessages:OpenDataChannel"
  #       ],
  #      "Resource": "*"
  #      }
  #   ]
  #}
  #EOF
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "efs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_role" "onlyoffice_task_role" {
  name = "onlyoffice-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role" "onlyoffice_task_execution_role" {
  name               = "onlyoffice-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

#resource "aws_iam_role_policy_attachment" "ecs_exec" {
#  policy_arn = aws_iam_policy.ecs_exec.arn
#  role = aws_iam_role.onlyoffice_task_execution_role.name
#}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.onlyoffice_task_role.name
  policy_arn = aws_iam_policy.ecs_exec.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_iam_role_policy_attachment" "efs_full_access" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.efs_full_access.arn
}
