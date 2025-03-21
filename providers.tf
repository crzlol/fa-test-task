provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Environment = var.env
    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks.cluster_name]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    config_path = ".terraform/terraform.tfstate" # the great workaround (dirty hack in fact) to force provider to use static configuration

    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
