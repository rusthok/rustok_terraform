### RDS
##
#
locals {
  kubewpdb-name = "kwordpressdb"
  kubewpdb-creds = {
    user = "kwordpressdbuser"
    pass = "kwprdpressdbpass"
  }
}

module "kwordpressdb" {
  source  = "cloudposse/rds-cluster/aws"
  version = "0.44.1"

  engine         = "aurora-mysql"
  engine_mode    = "provisioned"
  engine_version = "5.7.mysql_aurora.2.09.2"
  cluster_family = "aurora-mysql5.7"
  cluster_size   = 1
  name           = local.kubewpdb-name
  admin_user     = local.kubewpdb-creds.user
  admin_password = local.kubewpdb-creds.pass
  db_name        = local.kubewpdb-name
  instance_type  = var.rds-instance-type[var.stage]
  vpc_id         = aws_vpc.vpc.id
  subnets        = [aws_subnet.private_DBsubnet1.id, aws_subnet.private_DBsubnet2.id]
  security_groups = [
    #aws_security_group.kube-wp-sg.id,#to be defined
    #module.eks.cluster_primary_security_group_id #to be define
    aws_security_group.DBsecuritygroup.id, module.eks.cluster_primary_security_group_id

  ]
}