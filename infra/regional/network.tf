######################################################################################################
###################################################################################################### VPC
resource "aws_vpc" "aws_k3s" {
  cidr_block = "10.0.0.0/16"
  
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.env}_aws_k3s"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
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
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.aws_k3s.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.list.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}_aws_k3s_public2"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.aws_k3s.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.list.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.env}_aws_k3s_private1"
    # "kubernetes.io/cluster/${var.cluster_id}" = "owned"
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
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws_k3s.id
  tags = {
    Name = "${var.env}_aws_k3s_public"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.aws_k3s.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route.public.route_table_id
  subnet_id = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route.public.route_table_id
  subnet_id = aws_subnet.public2.id
}


#########
# PRIVATE
#########
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aws_k3s.id
  tags = {
    Name = "${var.env}_aws_k3s_private"
  }
}

# resource "aws_route_table_association" "private" {
#   route_table_id = aws_route.public.route_table_id
#   subnet_id = aws_subnet.private1.id
# }

