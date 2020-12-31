terraform {
  // Testing Terraform v0.13.5
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
