locals {
  output = {
    "/shared/onlyoffice_cluster_id"     = aws_ecs_cluster.onlyoffice.id
    "/shared/iam/allow_ssm_secrets_arn" = aws_iam_policy.allow_ssm_secrets.arn
  }
}

resource "aws_ssm_parameter" "outputs" {
  for_each = local.output
  name     = each.key
  type     = "String"
  value    = each.value
}