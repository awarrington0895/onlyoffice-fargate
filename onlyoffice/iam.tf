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
    effect = "Allow"
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
}

data "aws_iam_policy" "cloudwatch_agent_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ssm_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "efs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_role" "onlyoffice_task_role" {
  name               = "onlyoffice-task-role"
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

resource "aws_iam_role_policy_attachment" "allow_ssm_secrets" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = local.allow_ssm_secrets_arn
}

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

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_to_task" {
  role       = aws_iam_role.onlyoffice_task_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_readonly" {
  role       = aws_iam_role.onlyoffice_task_execution_role.name
  policy_arn = data.aws_iam_policy.ssm_readonly.arn
}
