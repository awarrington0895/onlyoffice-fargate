provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "asw-sample-tf-backend-3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.0"
    }
  }
}