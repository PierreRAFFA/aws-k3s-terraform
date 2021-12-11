# # Elastic Load Balancing distributes incoming application or network traffic across multiple targets,
# # such as Amazon EC2 instances, containers, and IP addresses, in multiple Availability Zones.
# # Elastic Load Balancing scales your load balancer as traffic to your application changes over time.
# # It can automatically scale to the vast majority of workloads.
# # For the `load_balancer_type` see https://aws.amazon.com/elasticloadbalancing/features/#compare
# resource "aws_lb" "aws_k3s_api" {
#   name = "${var.env}-aws-k3s-api"
#   load_balancer_type = "application"
#   internal = false
#   security_groups = [aws_security_group.aws_k3s_api_lb.id]

#   //to the public subnets as the service is exposed to the world
#   subnets = [
#     aws_subnet.public1.id,
#     aws_subnet.public2.id,
#   ]

#   access_logs {
#     bucket  = aws_s3_bucket.aws_k3s_lb.bucket
#     prefix  = "" // no prefix
#     enabled = true
#   }

# }

# # Loadbalancer and its target group
# resource "aws_lb_target_group" "aws_k3s_api" {
#   name     = "${var.env}-aws-k3s-api"
#   port     = 6443
#   protocol = "TCP"
#   vpc_id   = aws_vpc.aws_k3s.id

#   health_check {
#     healthy_threshold   = "5"
#     unhealthy_threshold = "2"
#     interval            = "30"
#     matcher             = "401"
#     path                = "/livez"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = "5"
#   }

# }

# resource "aws_security_group" "aws_k3s_api_lb" {
#   name        = "${var.env}-aws-k3s-api-lb"
#   description = "For k3s api"
#   vpc_id      = aws_vpc.aws_k3s.id

#   ingress {
#     from_port         = 6443
#     protocol          = "-1"
#     to_port           = 6443
#     cidr_blocks       = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port         = 0
#     protocol          = "-1"
#     to_port           = 0
#     cidr_blocks       = ["0.0.0.0/0"]
#   }
# }

# Enable access logs for the Load Balancer
# https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
##########################################

resource "aws_s3_bucket" "aws_k3s_lb" {
  bucket = "${var.env}-aws-k3s-lb"
  acl    = "private"

  # 652711504416 ELB Account Id for eu-west-2 (see link above)
  policy = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::652711504416:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.env}-aws-k3s-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.env}-aws-k3s-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.env}-aws-k3s-lb"
    }
  ]
}
EOL

  lifecycle_rule {
    enabled = true

    expiration {
      days = 90
    }
  }
}
