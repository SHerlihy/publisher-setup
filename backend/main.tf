terraform {
  required_version = ">= 1.0, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "aws" {
  profile = "publisher_admin"
  region  = "eu-west-2"
}

locals {
  common_tags = {
    product_id = "quota endpoint"
    facet      = "admin"
  }
}

resource "aws_s3_bucket" "backend" {
  bucket_prefix = "publisher-setup-"

  tags = merge(local.common_tags, {})

  lifecycle {
    prevent_destroy = true
  }
}

output "id" {
  value = aws_s3_bucket.backend.id
}
