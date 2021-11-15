################################################################################################################
################################################################################################################
resource "aws_security_group" "aws_k3s_access" {
  name        = "${var.env}_aws_k3s_access"
  description = "intranet access security group for ecs hosts"
  vpc_id      = aws_vpc.aws_k3s.id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}_aws_k3s_access"
  }
}

resource "aws_security_group" "aws_k3s_ssh" {
  name   = "${var.env}_aws_k3s_ssh"
  vpc_id = aws_vpc.aws_k3s.id

  ingress {
    //    cidr_blocks = ["0.0.0.0/0"]   # <==== Once the bastion created, we can specify the security_groups related to the bastion
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    # security_groups = [aws_security_group.bastion_ssh.id] # <====== security_groups specified here
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}_aws_k3s_ssh"
  }
}