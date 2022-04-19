
##create network security groups
resource "aws_security_group" "publicNSG" {
  name   = "publicNSG"
  vpc_id = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = var.rulesPublic
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "privateNSG" {
  name   = "privateNSG"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.publicNSG.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.publicNSG.id]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.publicNSG.id]
  }
#  ingress {
#    from_port       = 80
#    to_port         = 80
#    protocol        = "tcp"
#    security_groups = [aws_security_group.applbNSG.id]
#  }
#  ingress {
#    from_port       = 8080
#    to_port         = 80
#    protocol        = "tcp"
#    security_groups = [aws_security_group.applbNSG.id]
#  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_security_group" "DBsecuritygroup" {
  name   = "DBsecuritygroup"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.privateNSG.id] #to be fixed
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  #  dynamic "ingress" {
  #    for_each = var.rulesPrivate
  #    content {
  #      from_port       = ingress.value["port"]
  #      to_port         = ingress.value["port"]
  #      protocol        = ingress.value["proto"]
  #      security_groups = ingress.value["security_groups"]
  #    }
  #  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

#resource "aws_security_group" "applbNSG" {
#  name        = "alb_security_group"
#  description = "load balancer security group"
#  vpc_id      = aws_vpc.vpc.id
#  dynamic "ingress" {
#    for_each = var.rulesALB
#    content {
#      from_port   = ingress.value["port"]
#      to_port     = ingress.value["port"]
#      protocol    = ingress.value["proto"]
#      cidr_blocks = ingress.value["cidr_blocks"]
#    }
#  }
#  # Allow all outbound traffic.
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
