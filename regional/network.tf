######################################################################################################
###################################################################################################### VPC
resource "aws_vpc" "aws_k3s" {
  cidr_block = "10.0.0.0/16"
  
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.env}_aws_k3s"
    Env = var.env
  }
}

######################################################################################################
###################################################################################################### SUBNETS
data "aws_availability_zones" "list" {}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.aws_k3s.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.list.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}_aws_k3s_public1"
    Env = var.env
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.aws_k3s.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.list.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.env}_aws_k3s_private1"
    Env = var.env
  }
}
######################################################################################################
###################################################################################################### ROUTE TABLES

########
# PUBLIC
########
resource "aws_internet_gateway" "aws_k3s" {
  vpc_id = aws_vpc.aws_k3s.id
  tags = {
    Name = "${var.env}_aws_k3s"
    Env = var.env
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws_k3s.id
  tags = {
    Name = "${var.env}_aws_k3s_public"
    Env = var.env
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.aws_k3s.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route.public.route_table_id
  subnet_id = aws_subnet.public1.id
}



#########
# PRIVATE
#########
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aws_k3s.id
  tags = {
    Name = "${var.env}_aws_k3s_private"
    Env = var.env
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route.public.route_table_id
  subnet_id = aws_subnet.private1.id
}

# resource "aws_route" "public" {
#   route_table_id = aws_route_table.public.id
#   nat_gateway_id = aws_nat_gateway.aws_k3s.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# Disabled so far as it's not free
#
# resource "aws_nat_gateway" "aws_k3s" {
#   subnet_id = aws_subnet.private1.id
#   allocation_id = aws_eip.aws_k3s.id
#   tags = {
#     Name = "${var.env}_aws_k3s"
#     Env = var.env
#   }
# }

# resource "aws_eip" "aws_k3s" {
#   vpc = aws_vpc.aws_k3s.id
#   tags = {
#     Name = "${var.env}_aws_k3s"
#     Env = var.env
#   }
# }
######################################################################################################
###################################################################################################### SECURITY GROUP

