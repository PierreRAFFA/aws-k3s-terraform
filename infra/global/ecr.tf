resource "aws_ecr_repository" "app1" {
  provider = aws.eu-west-2
  name                 = "app1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "app2" {
  provider = aws.eu-west-2
  name                 = "app2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
