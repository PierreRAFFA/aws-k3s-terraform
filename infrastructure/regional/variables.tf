variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "eu-west-2"
}

variable "env" {
  default = "prod"
}

variable "num_masters" {
  default = 1
}

variable "num_workers" {
  default = 1
}


variable "containerPort" {
  default = 80
}

variable "cluster_id" {
  default = "aws-k3s"
}
