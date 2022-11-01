locals {
  output = {
    "/ecr/repository_url" = aws_ecr_repository.demo.repository_url
  }
}

resource "aws_ssm_parameter" "outputs" {
  for_each = local.output
  name     = each.key
  type     = "String"
  value    = each.value
}