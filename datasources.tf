data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
}

data "aws_eks_addon_version" "this" {
  for_each = local.eks_addons

  addon_name         = each.key
  kubernetes_version = var.k8s_version
  most_recent        = true
}

data "kubernetes_service" "nginx" {
  metadata {
    name      = helm_release.nginx.name
    namespace = helm_release.nginx.namespace
  }
}
