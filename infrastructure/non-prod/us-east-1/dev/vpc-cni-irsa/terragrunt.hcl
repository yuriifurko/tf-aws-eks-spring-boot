include "root" {
  path = find_in_parent_folders()
}

include "vpc+cni_irsa" {
  path   = "${dirname(find_in_parent_folders())}/_common/vpc-cni-irsa.hcl"
  expose = true
}

dependency "datasources" {
  config_path = "${get_terragrunt_dir()}/../data-sources"
  mock_outputs = {
    availability_zones = [
      "us-east1-a",
      "us-east1-b",
      "us-east1-c"
    ]
  }
}

inputs = {
  oidc_providers = {
    main = {
      provider_arn               = "" #module.eks.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}