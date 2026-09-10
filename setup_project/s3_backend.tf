resource "aws_s3_bucket" "backend" {
  bucket_prefix = "publisher-backend-"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {})
}

resource "aws_s3_object" "users" {
  for_each = local.usernames
  bucket   = aws_s3_bucket.backend.id
  key      = "${each.value}/"
}

data "aws_iam_policy_document" "all_user_access" {
  source_policy_documents = concat(local.dev_policies_json, [data.aws_iam_policy_document.s3_all_cicd_user.json])
}

resource "aws_s3_bucket_policy" "s3_path_developer_users" {
  bucket   = aws_s3_bucket.backend.id
  policy   = data.aws_iam_policy_document.all_user_access.json
}

output "backend_id" {
  value = aws_s3_bucket.backend.id
}
