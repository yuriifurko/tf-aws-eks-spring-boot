include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "eks_cluster" {
  path   = "${dirname(find_in_parent_folders())}/_common/eks-cluster.hcl"
  expose = true
}

dependency "vpc_cni_irsa" {
  config_path  = "${get_terragrunt_dir()}/../vpc-cni-irsa"
  mock_outputs = {
    iam_role_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  }
}

dependency "vpc_network" {
  config_path = "${get_terragrunt_dir()}/../vpc-network"

  mock_outputs = {
    vpc_id         = "vpc-00000000"
    vpc_cidr_block = "0.0.0.0/0"
    vpc_public_subnets_id = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]

    vpc_private_subnets_id = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}

inputs = {
  vpc_id             = dependency.vpc_network.outputs.vpc_id
  cluster_subnet_ids = dependency.vpc_network.outputs.vpc_private_subnets_id

  eks_cluster_security_group_ingress_cidr_blocks = {
    "443" = {
      "description" = "Allow internal connection to EKS API endpoind from OpenVPN server"
      "cidrs" = [
        dependency.vpc_network.outputs.vpc_cidr_block
      ]
      "from_port" = 443
      "to_port"   = 443
      "protocol"  = "tcp"
    }
  }

  eks_managed_node_group_enabled = false
  eks_managed_node_groups = {
    "frontend" = {
      enabled    = false
      name       = "frontend"
      subnet_ids = dependency.vpc_network.outputs.vpc_private_subnets_id

      instance_types = ["t3a.medium"] # limit 17 pods per node
      disk_type      = "gp3"
      disk_size      = 20

      min_size     = 2
      desired_size = 2
      max_size     = 2
    },
    "backend" = {
      enabled    = false
      name       = "backend"
      subnet_ids = dependency.vpc_network.outputs.vpc_private_subnets_id

      instance_types = ["t3a.medium"]
      disk_type      = "gp3"
      disk_size      = 20

      min_size     = 1
      desired_size = 1
      max_size     = 1
    }
  }

  # required aws-auth module
  self_managed_node_group_enabled = true
  self_managed_node_group = {
    name = "default"

    vpc_zone_identifier = dependency.vpc_network.outputs.vpc_private_subnets_id

    instance_type = "t3a.medium" # limit 110 pods per node
    disk_type     = "gp3"
    disk_size     = 20

    desired_capacity = 2
    min_size         = 2
    max_size         = 2
  }

  eks_access_entry_policy = {
    "devops" = {
      enabled       = true
      principal_arn = "arn:aws:iam::935454902317:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_1b22a202a6b807d7"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      type          = "STANDARD"
      user_name     = "AWSAdministratorAccess"

      kubernetes_groups = null

      association_access_scope_type = "cluster"
    }
  }

  eks_addons = {
    "kube-proxy" = {
      enabled        = true
      addon_name     = "kube-proxy"
      addon_version  = "v1.29.1-eksbuild.2"
    },
    "coredns" = {
      enabled        = true
      addon_name     = "coredns"
      addon_version  = "v1.11.1-eksbuild.6"
    },
    "vpc-cni" = {
      enabled        = true
      addon_name     = "vpc-cni"
      addon_version  = "v1.18.0-eksbuild.1"
      role_arn       = dependency.vpc_cni_irsa.outputs.iam_role_arn

      configs = jsonencode({
        env = {
          # Reference docs
          # https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          # https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
}