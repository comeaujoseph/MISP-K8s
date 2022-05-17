data "aws_vpc" "MISP_VPC" {
  tags = "${map("kubernetes.io/cluster/${var.k8s_cluster_name}", "shared")}"
}

data "aws_subnet_ids" "MISP_subnets" {
  vpc_id = data.aws_vpc.MISP_VPC.id
}

data "aws_security_group" "MISP_node_ext" {
  filter {
    name = "tag:Name"
    values = ["${var.eks_cluster_name}-node-ext-sg"]
  }
}

# DNS Zone used to deploy MISP and MISP-Dashboard
data "aws_route53_zone" "managed_zone" {
  name         = "${local.config.network.hosted_zone}."
  private_zone = false
}