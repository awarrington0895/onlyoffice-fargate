provider "aws" {
  region = "us-east-1"
  profile = "acloudguru"
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "asw-sample-tf-backend"
    key = "terraform.tfstate"
    region = "us-east-1"
    profile = "default"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
}