include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "aws_ecr_repositories" {
  path   = "${dirname(find_in_parent_folders())}/_common/ecr-repositories.hcl"
  expose = false
}

inputs = {
  repositories = {
    "spring-boot" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 7
    },
    "nginx" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 7
    },
    "frontend" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 3
    },
    "backend" = {
      image_tag_mutability  = "IMMUTABLE"
      scan_on_push          = true
      expiration_after_days = 0 # no expiration policy set
    }
  }

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  manage_registry_scanning_configuration = true
  registry_scan_type = "BASIC"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
    }
  ]
}
