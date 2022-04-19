#prerequisites
##manually create a key pair called "key", a dynamoDB table (backendTerraformLockTable) and a S3Bucket (mybackendterraformawss3) with corresponding policies
###run aws configure with access key and secret access key
##configure github actions with the correct access key and secret access key in the github secrets to let autotrigger the deployment with each push
#Test every change on the code
#terraform init -backend-config="access_key=AKIAVHZDA4G74B7C6SUR" -backend-config="secret_key=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"
#aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
#aws eks --region us-east-1 update-kubeconfig --name wordpress-eks-2u4c9xQJ
#kubectl get nodes
#kubectl get nodes -A
#kubectl describe pod wordpress-7f78bb5f98-4pq22
#
#

terraform {
  required_version = ">= 0.13"
  backend "s3" {
    profile        = "Task-demoWordpress"
    region         = "us-east-1"
    key            = "terraform.tfstate"
    bucket         = "mybackendterraformawss3"
    dynamodb_table = "backendTerraformLockTable"
  }
  cloud {
    organization = "rustok"

    workspaces {
      name = "rustok_terraform"
    }
  }
}



module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  #cluster_version = "1.20"
  subnets = [aws_subnet.private_wordpresssubnet1.id, aws_subnet.private_wordpresssubnet2.id]
  tags = {
    Name = "WordpressKubernetesCluster"
  }

  vpc_id = aws_vpc.vpc.id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "wordpress-worker-group-1a"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.privateNSG.id]
    },
    {
      name                          = "wordpress-worker-group-1b"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.privateNSG.id]
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}



resource "aws_instance" "jumpbox-a" {
  ami           = data.aws_ssm_parameter.amazon-ami.value
  instance_type = "t2.micro"
  #key_name                    = aws_key_pair.key.key_name
  key_name                    = "key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.publicNSG.id]
  subnet_id                   = aws_subnet.public_subnet1.id
  #user_data                   = fileexists("webserverinstallation.sh") ? file("webserverinstallation.sh") : null
  user_data = <<EOF
#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
echo "<h1><center>" > index.html
echo "Hello World from $(hostname -f) for R/&D_EPAM" >> index.html
echo "</center></h1>" >> index.html
mv index.html /var/www/html/
EOF
  #  provisioner "remote-exec" {
  #    inline = [
  #      "sudo yum -y update && sudo yum -y install httpd && sudo systemctl start httpd",
  #      "echo '<h1><center>Jumpbox-a</center></h1>' > index.html",
  #      "sudo mv index.html /var/www/html/"
  #    ]
  #    connection {
  #      type        = "ssh"
  #      user        = "ec2-user"
  #      private_key = file("~/.ssh/id_rsa.pub")
  #      host        = self.public_ip
  #    }
  #  }
  tags = {
    Name = "jumpbox-a"
  }
}

#ami
#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "amazon-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}







#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": "arn:aws:iam::360313840063:user/cloud_user"
#            },
#            "Action": "s3:ListBucket",
#            "Resource": "arn:aws:s3:::mybackendterraformawss3"
#        },
#        {
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": "arn:aws:iam::360313840063:user/cloud_user"
#            },
#            "Action": [
#                "s3:GetObject",
#                "s3:PutObject",
#                "s3:DeleteObject"
#            ],
#            "Resource": "arn:aws:s3:::mybackendterraformawss3/*"
#        }
#    ]
#}
#

