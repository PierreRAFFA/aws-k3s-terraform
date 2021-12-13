# Get `ms-users` load balancer created by k3s 
data "aws_resourcegroupstaggingapi_resources" "ms_users_lb_filter" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "kubernetes.io/service-name"
    values = ["default/ms-users"]
  }
}

data "aws_elb" "ms_users_lb" {
  name = split("/", data.aws_resourcegroupstaggingapi_resources.ms_users_lb_filter.resource_tag_mapping_list[0].resource_arn)[1]
}

# Get `ms-payments` load balancer created by k3s 
data "aws_resourcegroupstaggingapi_resources" "ms_payments_lb_filter" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "kubernetes.io/service-name"
    values = ["default/ms-payments"]
  }
}

data "aws_elb" "ms_payments_lb" {
  name = split("/", data.aws_resourcegroupstaggingapi_resources.ms_payments_lb_filter.resource_tag_mapping_list[0].resource_arn)[1]
}
