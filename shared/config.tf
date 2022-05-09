provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "asw-sample-tf-backend-4"
    key    = "shared/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.0"
    }
  }
}