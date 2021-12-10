################################################################################################################
################################################################################################################
resource "aws_security_group" "aws_k3s_main" {
  name        = "${var.env}_aws_k3s_main"
  description = "for k3s cluster"
  vpc_id      = aws_vpc.aws_k3s.id

  # Access via http 
  # Todo: might be better to add this only for the workers
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Access via ssh
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kube api port
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Those sharing the same sg can access to the resource
  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}_aws_k3s_api"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}
