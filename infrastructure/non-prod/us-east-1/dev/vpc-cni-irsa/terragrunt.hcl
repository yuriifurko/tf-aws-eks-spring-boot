include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "vpc_cni_irsa" {
  path   = "${dirname(find_in_parent_folders())}/_common/vpc-cni-irsa.hcl"
  expose = true
}

# dependency "eks_cluster" {
#   config_path = "${get_terragrunt_dir()}/../eks-cluster"
#   mock_outputs = {
#     eks_cluster_identity_oidc_issuer_arn = "arn:aws:iam::000000000000:role/${include.root.locals.project_name}-${include.root.locals.environment}"
#   }
# }

inputs = {
  oidc_providers = {
    # issue: * Found a dependency cycle between modules: ./terragrunt.hcl -> ../eks-cluster/terragrunt.hcl -> ./terragrunt.hcl
    main = {
      provider_arn               = "arn:aws:iam::935454902317:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/105B8878CAA558B7851646C816A194F5" #try(dependency.eks_cluster.outputs.eks_cluster_identity_oidc_issuer_arn, null)
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}