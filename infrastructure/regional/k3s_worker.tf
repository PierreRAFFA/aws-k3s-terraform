resource "aws_autoscaling_group" "aws_k3s_worker" {
  name = "${var.env}_aws_k3s_worker"
  max_size = 2
  min_size = 0
  launch_configuration = aws_launch_configuration.aws_k3s_worker.name
  vpc_zone_identifier = [aws_subnet.public1.id]

  lifecycle {
    create_before_destroy = true
  }

  # Set these tags to the instances created by asg
  tags = [{
    key = "Name"
    value = "${var.env}_aws_k3s_worker"
    propagate_at_launch = true
  },{
    key = "Env"
    value = "${var.env}_aws_k3s_worker"
    propagate_at_launch = true
  },{
    key = "kubernetes.io/cluster/${var.cluster_id}"
    value = "owned"
    propagate_at_launch = true
  }]
}

################################################################################################################
################################################################################################################
# In order to effectively use a Launch Configuration resource with an AutoScaling Group resource,
# it's recommended to specify create_before_destroy in a lifecycle block.
# Either omit the Launch Configuration name attribute, or specify a partial name with name_prefix.
resource "aws_launch_configuration" "aws_k3s_worker" {
  name_prefix = "${var.env}_aws_k3s_worker"
  image_id = "ami-033fbb55f5a2a0f37" # amazon/amzn2-ami-hvm-2.0.20210421.0-x86_64-ebs
  instance_type = "t3.micro"

  key_name = aws_key_pair.aws_k3s_admin.key_name
  
  # An instance profile is a container for an IAM role that you can use to pass role information to an EC2 instance when the instance starts.
  iam_instance_profile = aws_iam_instance_profile.aws_k3s_worker.name

  # Needed to connect via ssh
  associate_public_ip_address = true # <==== Once the bastion created, we can make it false

  lifecycle {
    create_before_destroy = true
  }

  # By default, your container instance launches into your default cluster. To launch into a non-default cluster,
  # choose the Advanced Details list. Then, paste the following script into the User data field,
  # replacing your_cluster_name with the name of your cluster.
  # More info here https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
  user_data = data.template_file.aws_k3s_userdata_worker.rendered

  security_groups = [
    aws_security_group.aws_k3s_main.id
  ]
}

# resource "aws_security_group" "aws_k3s_worker_http" {
#   name   = "${var.env}_aws_k3s_worker_http"
#   vpc_id = aws_vpc.aws_k3s.id

#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.env}_aws_k3s_worker_http"
#     "kubernetes.io/cluster/${var.cluster_id}" = "owned"
#   }
# }

data "template_file" "aws_k3s_userdata_worker" {
  template = "${file("userdata_worker_docker.tpl")}"
  vars = {
    region = var.region
    secretsmanager_secret_id = aws_secretsmanager_secret.aws_k3s_token.name
  }
}

################################################################################################################
################################################################################################################
# An instance profile is a container for an IAM role that you can use to pass role information to an EC2 instance
# when the instance starts.
# An instance profile can contain only one IAM role, although a role can be included in multiple instance profiles.
resource "aws_iam_instance_profile" "aws_k3s_worker" {
  name = "${var.env}_aws_k3s_worker"
  path = "/"
  role = aws_iam_role.aws_k3s_worker.name
}

resource "aws_iam_role" "aws_k3s_worker" {
  name = "${var.env}_aws_k3s_worker_instance_profile"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
