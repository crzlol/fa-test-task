terraform {
  backend "local" {}
}

locals {
  eks_addons = {
    vpc-cni    = { env = { ENABLE_PREFIX_DELEGATION = "true" } }
    coredns    = {}
    kube-proxy = {}
  }

  eks_cluster_oidc_provider = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")
  aws_account_id            = data.aws_caller_identity.current.account_id

  cluster_autoscaler_sa_name   = "cluster-autoscaler"
  cluster_autoscaler_namespace = "kube-system"
}
