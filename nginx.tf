resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "nginx"

  namespace     = "default"
  recreate_pods = true
  wait          = true

  dynamic "set" {
    for_each = {
      "autoscaling.enabled"       = true
      "autoscaling.minReplicas"   = "1"
      "autoscaling.maxReplicas"   = "4"
      "autoscaling.targetCPU"     = "10"
      "resources.requests.cpu"    = "1000m"
      "resources.requests.memory" = "300M"
      "resources.limits.cpu"      = "1000m"
      "resources.limits.memory"   = "300M"
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
