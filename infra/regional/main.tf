provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "pierreraffa"
    workspace_key_prefix = "aws_k3s"
    key    = "terraform.json"
  }
}

data "aws_caller_identity" "current" {}