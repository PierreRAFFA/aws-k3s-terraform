# # Before you start using your Application Load Balancer, you must add one or more listeners. A listener is a process that
# # checks for connection requests, using the protocol and port that you configure.
# # The rules that you define for a listener determine how the load balancer routes requests to its registered targets.
# resource "aws_lb_listener" "aws_k3s_api" {
#   load_balancer_arn = aws_lb.aws_k3s.arn
#   port = 6443
#   protocol = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.aws_k3s_api.arn
#   }

#   # To prevent:
#   # Error deleting Target Group: ResourceInUse: Target group 'arn:aws:xxxx' is currently in use by a listener or a rule
#   //  lifecycle {
#   //    create_before_destroy = true
#   //  }
# }


# # Loadbalancer and its target group
# resource "aws_lb_target_group" "aws_k3s_api" {
#   name     = "${var.env}-aws-k3s-api"
#   port     = 6443
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.aws_k3s.id

#   tags = {
#     Environment = var.env
#   }
# }

