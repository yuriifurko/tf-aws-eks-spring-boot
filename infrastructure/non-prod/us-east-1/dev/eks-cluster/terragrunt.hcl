include "root" {
  path = find_in_parent_folders()
}

include "eks_cluster" {
  path   = "${dirname(find_in_parent_folders())}/_common/eks-cluster.hcl"
  expose = false
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
      disk_type      = "gp2"
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
      disk_type      = "gp2"
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
}