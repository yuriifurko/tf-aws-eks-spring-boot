include "root" {
  path = find_in_parent_folders()
}

include "aws_ebs_csi_driver" {
  path   = "${dirname(find_in_parent_folders())}/_common/aws-ebs-csi-driver.hcl"
  expose = true
}

dependency "datasources" {
  config_path = "${get_terragrunt_dir()}/../../data-sources"
  mock_outputs = {
    region = "us-east-0"
    availability_zones = [
      "us-east1-a",
      "us-east1-b",
      "us-east1-c"
    ]
  }
}

dependency "eks_cluster" {
  config_path = "${get_terragrunt_dir()}/../../eks-cluster"
}

generate "eks_providers" {
  path      = "eks_providers.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
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

}