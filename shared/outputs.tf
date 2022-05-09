locals {
  output = {
    "/shared/onlyoffice_cluster_id" = aws_ecs_cluster.onlyoffice.id
  }
}

resource "aws_ssm_parameter" "outputs" {
  for_each = local.output
  name     = each.key
  type     = "String"
  value    = each.value
}