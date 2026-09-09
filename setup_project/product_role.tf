data "aws_iam_policy_document" "product_assume_role" {
  statement {
    sid     = "AllowDevelopersToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [for user in aws_iam_user.developers : user.arn]
    }
  }
}

resource "aws_iam_role" "product" {
  name               = "quota-endpoint-api-gateway"
  assume_role_policy = data.aws_iam_policy_document.product_assume_role.json

  tags = merge(local.common_tags, {})
}

data "aws_iam_policy_document" "product_api_gateway" {
  statement {
    sid    = "ManageApiGatewayEndpoints"
    effect = "Allow"

    actions = [
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "product_api_gateway" {
  name   = "manage-api-gateway-endpoints"
  role   = aws_iam_role.product.id
  policy = data.aws_iam_policy_document.product_api_gateway.json
}

data "aws_iam_policy_document" "product_assume_role_for_user" {
  for_each = aws_iam_user.developers

  statement {
    sid       = "AssumeQuotaEndpointApiGatewayRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.product.arn]
  }
}

resource "aws_iam_user_policy" "product_assume_role" {
  for_each = data.aws_iam_policy_document.product_assume_role_for_user

  name   = "assume-quota-endpoint-api-gateway"
  user   = each.key
  policy = each.value.json
}

output "product_role_arn" {
  value = aws_iam_role.product.arn
}
