terraform {
  required_version = ">= 1.0, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, <7.0"
    }
  }

  backend "s3" {
    bucket  = "publisher-setup-3b34e62ca5e651b4574b4ed3c4"
    key     = "setup_project/terraform.tfstate"
    profile = "publisher_admin"
    region  = "eu-west-2"
  }
}

provider "aws" {
  profile = "publisher_admin"
  region  = "eu-west-2"
}
