resource "aws_ecr_repository" "ms-users" {
  provider = aws.eu-west-2
  name                 = "ms-users"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ms-payments" {
  provider = aws.eu-west-2
  name                 = "ms-payments"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
