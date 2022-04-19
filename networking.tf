variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}


locals {
  cluster_name = "wordpress-eks-02032022" #"wordpress-eks-${random_string.suffix.result}"
}

#resource "random_string" "suffix" {
#  length  = 8
#  special = false
#}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.mainvpcIP
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id # vpc_id will be taken from vpc to be attached
}

##EIP
resource "aws_eip" "elasticIP1" { #elasticIPNatGateway1
  vpc = true
}
resource "aws_eip" "elasticIP2" { #elasticIPNatGateway2
  vpc = true
}


##NAT
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.elasticIP1.id        # attaching elasticIP
  subnet_id     = aws_subnet.public_subnet1.id #will be attached to public_subnet1
  #availability_zone = "us-east-1a"
}
resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.elasticIP2.id        # attaching elasticIP
  subnet_id     = aws_subnet.public_subnet2.id #will be attached to public_subnet2
  #availability_zone = "us-east-1a"
}

##Subnets
resource "aws_subnet" "public_subnet1" { # Public Subnet
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.publicsubnetrange[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "public_subnet2" { # Public Subnet2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.publicsubnetrange[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public"
  }

}

resource "aws_subnet" "private_wordpresssubnet1" { #Private WordpressSubnet1
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.privatesubnetrange[0]
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_wordpresssubnet2" { #Private WordpressSubnet2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.privatesubnetrange[1]
  availability_zone = "us-east-1b"
}
resource "aws_subnet" "private_DBsubnet1" { #Private DB Subnet1
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.privatesubnetrange[2]
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_DBsubnet2" { #Private DB Subnet2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.privatesubnetrange[3]
  availability_zone = "us-east-1b"
}

# Creating RT for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.internetIP
    gateway_id = aws_internet_gateway.igw.id
  }
}

##Creating RT for Private Subnet
resource "aws_route_table" "private_rt1-a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = var.internetIP
    nat_gateway_id = aws_nat_gateway.nat1.id
  }
}
resource "aws_route_table" "private_rt1-b" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = var.internetIP
    nat_gateway_id = aws_nat_gateway.nat2.id
  }
}


##route table subnet associations
resource "aws_route_table_association" "public_rt_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association1_a" {
  subnet_id      = aws_subnet.private_wordpresssubnet1.id
  route_table_id = aws_route_table.private_rt1-a.id
}

resource "aws_route_table_association" "private_rt_association2_a" {
  subnet_id      = aws_subnet.private_DBsubnet1.id
  route_table_id = aws_route_table.private_rt1-a.id
}
resource "aws_route_table_association" "private_rt_association1_b" {
  subnet_id      = aws_subnet.private_wordpresssubnet2.id
  route_table_id = aws_route_table.private_rt1-b.id
}

resource "aws_route_table_association" "private_rt_association2_b" {
  subnet_id      = aws_subnet.private_DBsubnet2.id
  route_table_id = aws_route_table.private_rt1-b.id
}


###ALB
#resource "aws_alb" "appLB" {
#  name            = "appLB"
#  security_groups = ["${aws_security_group.applbNSG.id}"]
#  subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
#  #####  #"[for subnet in data.aws_subnet_ids.public] " #"[for subnet in aws_subnet.public : subnet.id]" #["${aws_subnet.main.*.id}"]
#  tags = {
#    Name = "appLB"
#  }
#}
#
##experiment
#/*
#data "aws_subnet_ids" "public" {
#  vpc_id = var.vpc_id
#
#  tags = {
#    Name = "Public"
#  }
#}
#*/

#target group
#resource "aws_alb_target_group" "applbtargetgroup" {
#  name     = "applb-targetgroup"
#  port     = 8080
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.vpc.id
#  stickiness {
#    type = "lb_cookie"
#  }
#  # Alter the destination of the health check to be the index page.
#  health_check {
#    path = "/"
#    port = 8080
#  }
#}
#

##listener
#resource "aws_alb_listener" "listener_http" {
#  load_balancer_arn = aws_alb.appLB.arn
#  port              = "80"
#  protocol          = "HTTP"
#
#  default_action {
#    target_group_arn = aws_alb_target_group.applbtargetgroup.arn
#    type             = "forward"
#  }
#}
#

#####<EDIT
#resource attachment to target group
#resource "aws_lb_target_group_attachment" "targetgroupattachment" {
#  target_group_arn = aws_alb_target_group.applbtargetgroup.arn
#  target_id        = aws_instance.webserver-a.id
#  port             = 80
#}
#
#resource "aws_lb_target_group_attachment" "targetgroupattachment2" {
#  target_group_arn = aws_alb_target_group.applbtargetgroup.arn
#  target_id        = aws_instance.webserver-b.id
#  port             = 80
#}
#####EDIT>
