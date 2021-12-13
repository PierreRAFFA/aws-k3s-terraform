resource "aws_ecr_repository" "ms-users" {
  count = var.region == "eu-west-2" ? 1 : 0
  name                 = "ms-users"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ms-payments" {
  count = var.region == "eu-west-2" ? 1 : 0
  name                 = "ms-payments"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
