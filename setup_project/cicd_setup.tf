resource "aws_iam_user" "cicd" {
  name = "cicd"

  tags = merge(local.common_tags, {})
}

resource "aws_iam_access_key" "cicd" {
  user = aws_iam_user.cicd.name
}

data "aws_iam_policy_document" "s3_all_cicd_user" {
  statement {
    sid    = "s3ListCicdUser"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.cicd.arn]
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
      values   = ["cicd/", "cicd/*"]
    }
  }

  statement {
    sid    = "s3AllCicdUser"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.cicd.arn]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.backend.arn}/cicd/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_all_cicd_user" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.s3_all_cicd_user.json
}

output "cicd_access_key_id" {
  value = aws_iam_access_key.cicd.id
}

output "cicd_secret_access_key" {
  value     = aws_iam_access_key.cicd.secret
  sensitive = true
}
