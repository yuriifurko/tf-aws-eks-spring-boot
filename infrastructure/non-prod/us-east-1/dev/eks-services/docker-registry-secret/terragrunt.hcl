include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "docker_registry_secret" {
  path   = "${dirname(find_in_parent_folders())}/_common/docker-registry-secret.hcl"
  expose = false
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
EOF
}

inputs = {
  docker_registry_username = get_env("TF_VAR_docker_registry_username", "docker_registry_username")
  docker_registry_password = get_env("TF_VAR_docker_registry_password", "docker_registry_password")
  docker_registry_server   = get_env("TF_VAR_docker_registry_server", "docker_registry_server")
  docker_registry_email    = get_env("TF_VAR_docker_registry_email", "docker_registry_email")
}