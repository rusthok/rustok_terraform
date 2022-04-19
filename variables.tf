#
##
###NSG rules
##
#
variable "rulesPublic" {
  default = [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "rulesALB" {
  default = [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "rulesPrivate" {
  default = [
    {
      port            = 80
      proto           = "tcp"
      security_groups = "aws_security_group.publicNSG.id" #"aws_security_group.publicNSG.id" #[aws_security_group.publicNSG.id]
    },
    {
      port            = 22
      proto           = "tcp"
      security_groups = "aws_security_group.publicNSG.id" #"aws_security_group.publicNSG.id" #[aws_security_group.publicNSG.id]
    }
  ]
}



#
##
### CIDRS range of networks and subnets
##
#
variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  default     = ["11.0.1.0/24", "11.0.2.0/24"]
  type        = list(string)
}

variable "internetIP" {
  default = "0.0.0.0/0"
  type    = string
}

variable "publicsubnetrange" {
  default = ["11.0.1.0/24", "11.0.2.0/24"]
  type    = list(string)
}

variable "privatesubnetrange" {
  default = ["11.0.3.0/24", "11.0.4.0/24", "11.0.5.0/24", "11.0.6.0/24"]
  type    = list(string)
}

variable "mainvpcIP" {
  default = "11.0.0.0/16"
  type    = string
}


#
##
###AMI for jumpbox   #Get Linux AMI ID using SSM Parameter endpoint in us-east-1
##
#
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}



##
###RDS
##
variable "rds-instance-type" {
  default = {
    dev  = "db.t3.small"
    prod = "db.m6g.2xlarge"
  }
  type = object({
    dev  = string
    prod = string
  })
}

variable "stage" {
  default = "dev"
  type    = string
}