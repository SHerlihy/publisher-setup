resource "aws_iam_user" "developers" {
  for_each = local.usernames
  name     = each.value

  tags = merge(local.common_tags, {})
}

resource "aws_iam_access_key" "developers" {
  for_each = aws_iam_user.developers
  user     = each.value.name
}

locals {
  usernames_to_access_key = { for access_key in aws_iam_access_key.developers : access_key.user => { key_id : access_key.id, key_secret : access_key.secret } }
}

data "aws_iam_policy_document" "s3_path_developer_user" {
  for_each = aws_iam_user.developers

  statement {
    sid    = "list_bucket-${each.value.name}"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [each.value.arn]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.backend.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = ["${each.value.name}/", "${each.value.name}/*"]
    }
  }

  statement {
    sid    = "all_on_user_path-${each.value.name}"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [each.value.arn]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.backend.arn}/${each.value.name}/*",
    ]
  }
}

locals {
  dev_policies_json = [ for s3_dev_policy in data.aws_iam_policy_document.s3_path_developer_user : s3_dev_policy.json ]
}

output "usernames_to_access_key" {
  value     = local.usernames_to_access_key
  sensitive = true
}
