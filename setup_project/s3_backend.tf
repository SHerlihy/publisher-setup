resource "aws_s3_bucket" "backend" {
  bucket_prefix = "publisher-backend-"

  tags = merge(local.common_tags, {})

  lifecycle {
    prevent_destroy = true
  }
}

output "backend_id" {
  value = aws_s3_bucket.backend.id
}
