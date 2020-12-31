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

resource "kubernetes_persistent_volume_claim" "example" {
  metadata {
    name = "test-destroy-eks-auth"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_job" "test" {
  metadata {
    name = "test"
  }
  spec {
    template {
      metadata {
      }
      spec {
        container {
          image = "hello-world"
          name  = "hello"
          volume_mount {
            name       = "example"
            mount_path = "/mnt"
          }
        }
        restart_policy = "Never"
        volume {
          name = "example"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.example.metadata[0].name
          }
        }
      }
    }
  }
}
