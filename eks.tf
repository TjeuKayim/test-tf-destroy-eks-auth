data "aws_eks_cluster" "cluster" {
  name = module.my_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my_cluster.cluster_id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "my_cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.18"
  subnets         = data.aws_subnet_ids.all.ids
  vpc_id          = data.aws_vpc.default.id

  // Single node
  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 1
      asg_max_size         = 1
    }
  ]
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "example"
    labels = {
      app = "example"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
      }

      spec {
        container {
          image = "caddy:latest"
          name  = "example"

          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }

            initial_delay_seconds = 9
            period_seconds        = 30
            timeout_seconds       = 9
          }
        }
      }
    }
  }
}
