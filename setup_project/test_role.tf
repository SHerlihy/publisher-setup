data "aws_iam_policy_document" "test_role_assume_role" {
  statement {
    sid     = "AllowDevelopersToAssumeTestRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [for user in aws_iam_user.developers : user.arn]
    }
  }
}

resource "aws_iam_role" "test_api_gateway" {
  name               = "test-api-gateway"
  assume_role_policy = data.aws_iam_policy_document.test_role_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy" "test_api_gateway" {
  name = "create-api-gateway"
  role = aws_iam_role.test_api_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "CreateApiGateway"
      Effect = "Allow"
      Action = [
        "apigateway:GET",
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:PATCH",
        "apigateway:DELETE",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy" "test_api_gateway_assume_role" {
  for_each = aws_iam_user.developers

  name = "assume-test-api-gateway"
  user = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AssumeTestApiGatewayRole"
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.test_api_gateway.arn
    }]
  })
}

output "test_api_gateway_role_arn" {
  value = aws_iam_role.test_api_gateway.arn
}
