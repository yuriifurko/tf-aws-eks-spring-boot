include "root" {
  path = find_in_parent_folders()
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
  argocd_slack_token = "null"

  auth0_domain        = "dev-ocfok91r.eu.auth0.com"
  auth0_client_id     = "gKrhS93ttzDohFOiWyO3aOiVdpTfzcG6"
  auth0_client_secret = "p0CU1ZOpXBY35-y2cUjwNZlnpp1cdT4HEBqCawCqmRIXPcX6rIn_H7wCPHoHzAGV"

  # SSO
  argocd_sso_domain_name = format("https://%v", "argocd.dev.awsworkshop.info")

  argocd_server_values = concat(
    [
      yamlencode({
        server = {
          ingress = {
            enabled          = false
            ingressClassName = "nginx"
            hosts            = []
            paths            = ["/"]
            tls = [
              {
                secretName = "argocd-tls"
                hosts      = []
              }
            ]
          }
        }
      })
    ]
  )

  argocd_app_values = concat(
    [
      yamlencode({
        projects = [
          {
            name                  = "guestbook"
            namespace             = "argocd"
            description           = "GuestBook Project"
            additionalLabels      = {}
            additionalAnnotations = {}
            finalizers = [
              "resources-finalizer.argocd.argoproj.io"
            ]
            sourceRepos = [
              "*"
            ]
            destinations = [
              {
                namespace = "guestbook"
                server    = "https://kubernetes.default.svc"
              }
            ]
            clusterResourceWhitelist = []
            clusterResourceBlacklist = []
            namespaceResourceBlacklist = [
              {
                kind  = "ResourceQuota"
                group = "*"
              },
              {
                kind  = "LimitRange"
                group = "*"
              },
              {
                kind  = "NetworkPolicy"
                group = "*"
              }
            ]
            namespaceResourceWhitelist = []
            syncWindows = [
              {
                kind     = "allow"
                schedule = "10 1 * * *"
                duration = "1h"
                applications = [
                  "*-dev"
                ]
                manualSync = true
              }
            ]
            sourceNamespaces = [
              "argocd"
            ]
          }
        ]

        applications = [
          {
            name             = "guestbook"
            namespace        = "argocd"
            additionalLabels = {}
            additionalAnnotations = {
              "helm.sh/resource-policy" = "keep"
            }
            finalizers = [
              "resources-finalizer.argocd.argoproj.io"
            ]
            project = "guestbook"
            source = {
              repoURL        = "https://github.com/argoproj/argocd-example-apps.git"
              targetRevision = "HEAD"
              path           = "guestbook"
              directory = {
                recurse = true
              }
            }
            destination = {
              server    = "https://kubernetes.default.svc"
              namespace = "guestbook"
            }
            syncPolicy = {
              automated = {
                prune    = false
                selfHeal = false
              }
            }
            ignoreDifferences = [
              {
                group = "apps"
                kind  = "Deployment"
                jsonPointers = [
                  "/spec/replicas"
                ]
              }
            ]
            info = [
              {
                name  = "url"
                value = "https://argoproj.github.io/"
              }
            ]
          }
        ]

        ## Assign Application to a project
        applicationsets = [
          {
            name      = "guestbook"
            namespace = "argocd"
            generators = [
              {
                git = {
                  repoURL  = "https://github.com/argoproj/argocd-example-apps.git"
                  revision = "HEAD"
                  directories = [
                    {
                      path = "guestbook"
                    }
                  ]
                }
              }
            ]
            strategy = {
              type = "RollingSync"
            }
            template = {
              metadata = {
                name = "{{path.basename}}"
                labels = {
                  project = "{{path.basename}}"
                }
                annotations = {}
              }
              spec = {
                project = "guestbook"
                source = {
                  repoURL        = "https://github.com/argoproj/argocd-example-apps.git"
                  targetRevision = "HEAD"
                  path           = "{{path}}"
                }
                destination = {
                  server    = "https://kubernetes.default.svc"
                  namespace = "guestbook"

                }
                syncPolicy = {
                  automated = {
                    prune    = false
                    selfHeal = false
                  }
                }
                ignoreDifferences = [
                  {
                    group = "apps"
                    kind  = "Deployment"
                    jsonPointers = [
                      "/spec/replicas"
                    ]
                  }
                ]
                info = [
                  {
                    name  = "url"
                    value = "https://argoproj.github.io/"
                  }
                ]
              }
            }
            syncPolicy = {
              preserveResourcesOnDeletion = false
            }
          }
        ]
      })
    ]
  )
}