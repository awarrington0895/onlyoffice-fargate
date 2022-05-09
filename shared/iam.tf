data "aws_iam_policy_document" "allow_ssm_secrets" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameters"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_ssm_secrets" {
  name        = "allow_ssm_secrets"
  path        = "/"
  description = "Allow a resource to access SSM parameters"
  policy      = data.aws_iam_policy_document.allow_ssm_secrets.json
}