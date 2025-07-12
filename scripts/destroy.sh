terragrunt destroy --terragrunt-working-dir ../../us-east-1/dev/eks-cluser-auth
terragrunt destroy --terragrunt-working-dir ../../us-east-1/dev/vpc-cni-irsa

terragrunt destroy --terragrunt-working-dir ../../us-east-1/dev/eks-cluster
terragrunt destroy --terragrunt-working-dir ../../us-east-1/dev/vpc-network
