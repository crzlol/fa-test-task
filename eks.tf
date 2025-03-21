module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34"

  cluster_name    = "fa-${var.env}"
  cluster_version = var.k8s_version

  enable_irsa                     = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    fa-test-nginx = {
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = [var.eks_instance_type]

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size
    }
  }

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_eks_addon" "this" {
  for_each = local.eks_addons

  addon_name    = each.key
  cluster_name  = module.eks.cluster_name
  addon_version = data.aws_eks_addon_version.this[each.key].version

  configuration_values = each.value == null ? null : jsonencode(each.value)
}
