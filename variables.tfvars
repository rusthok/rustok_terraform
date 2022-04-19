variable "rulesPrivate" {
  default = [
    {
      port            = 80
      proto           = "tcp"
      security_groups = "aws_security_group.publicNSG.id"
    },
    {
      port            = 22
      proto           = "tcp"
      security_groups = "aws_security_group.publicNSG.id"
    }
  ]
}
