terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    region = "eu-west-2"
    bucket = "pierreraffa"
    workspace_key_prefix = "aws_k3s"
    key    = "terraform.json"
  }
}

provider "aws" {
  region = "eu-west-2"
  alias = "eu-west-2"
}
