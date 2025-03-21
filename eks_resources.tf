resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  namespace     = local.cluster_autoscaler_namespace
  recreate_pods = true
  wait          = true

  dynamic "set" {
    for_each = {
      "awsRegion"                                                      = data.aws_region.current.name
      "autoDiscovery.clusterName"                                      = module.eks.cluster_name
      "rbac.create"                                                    = "true"
      "rbac.serviceAccount.create"                                     = "true"
      "rbac.serviceAccount.name"                                       = local.cluster_autoscaler_sa_name
      "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.8.3"

  namespace     = local.cluster_autoscaler_namespace
  recreate_pods = true
  wait          = true
}
