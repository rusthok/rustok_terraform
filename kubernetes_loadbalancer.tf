#LB kubernetes
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
##parte del lb
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
#####parte del lb  
}




#####parte del lb  
variable "cluster_name" {
  type = string
  default = "wordpress-eks-02032022"
}


data "aws_eks_cluster" "example" {
  #depends_on = [module.eks]  #
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

# Create a local variable for the load balancer name.
locals {
# depends_on = [kubernetes_service.kservice]
  lb_name = split("-", split(".", kubernetes_service.kservice.status.0.load_balancer.0.ingress.0.hostname).0).0
  #lb_name = "wordpress-eks-02032022_lbname"
}

# Read information about the load balancer using the AWS provider.
data "aws_elb" "example" {
  name = local.lb_name
}

output "load_balancer_name" {
  value = local.lb_name
}

output "load_balancer_hostname" {
  value = kubernetes_service.kservice.status.0.load_balancer.0.ingress.0.hostname
}

output "load_balancer_info" {
  value = data.aws_elb.example
}
#####parte del lb  
