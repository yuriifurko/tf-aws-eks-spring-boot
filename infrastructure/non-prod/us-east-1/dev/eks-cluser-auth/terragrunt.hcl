include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "eks_cluser_auth" {
  path   = "${dirname(find_in_parent_folders())}/_common/eks-cluser-auth.hcl"
  expose = false
}

dependency "eks_cluster" {
  config_path = "${get_terragrunt_dir()}/../eks-cluster"
}

generate "eks_providers" {
  path      = "eks_providers.tf"
  if_exists = "overwrite_terragrunt"

  contents  = <<EOF
    data "aws_eks_cluster" "eks_cluster" {
      name = "${dependency.eks_cluster.outputs.eks_cluster_name}"
    }

    data "aws_eks_cluster_auth" "eks_cluster" {
      name = "${dependency.eks_cluster.outputs.eks_cluster_name}"
    }

    provider "kubernetes" {
      host                   = data.aws_eks_cluster.eks_cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
      token                  = data.aws_eks_cluster_auth.eks_cluster.token
    }

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.eks_cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
        token                  = data.aws_eks_cluster_auth.eks_cluster.token
      }
    }
EOF
}

inputs = {
  map_roles = []
  map_users = [
    {
      userarn  = "arn:aws:iam::${include.root.locals.account_id}:user/yurii.furko"
      username = "yurii.furko"
      groups = [
        "system:masters"
      ]
    },
    {
      userarn  = "arn:aws:iam::${include.root.locals.account_id}:user/test-user"
      username = "test-user"
      groups = [
        "none"
      ]
    }
  ]

  node_iam_role_arns = [
    try(dependency.eks_cluster.outputs.eks_cluster_self_managed_worker_node_iam_role_arn, null)
  ]
}