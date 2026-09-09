terraform {
  required_version = ">= 1.0, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, <7.0"
    }
  }

  backend "s3" {
    bucket  = "publisher-setup-c65056444609bf217224d69a1f"
    key     = "setup_project/terraform.tfstate"
    profile = "publisher_admin"
    region  = "eu-west-2"
  }
}

provider "aws" {
  profile = "publisher_admin"
  region  = "eu-west-2"
}
