locals {
  output = {
    "url"  = { name = "/ecr/repository_url", val = aws_ecr_repository.onlyoffice.repository_url }
  }
}

resource "aws_ssm_parameter" "outputs" {
  for_each = local.output
  name     = each.value.name
  type     = "String"
  value    = each.value.val
}