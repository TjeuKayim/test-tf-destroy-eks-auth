data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

module "eks" {
  # source          = "terraform-aws-modules/eks/aws"
  # version         = "14.0.0"
  # TODO: Wait for https://github.com/terraform-aws-modules/terraform-aws-eks/pull/1165 to be merged
  source          = "github.com/TjeuKayim/terraform-aws-eks"
  cluster_name    = "${var.cluster_name}-${var.environment}"
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
  workers_group_defaults = {
    root_volume_type = "gp2"
    root_volume_size = 30
  }

  iam_path = var.iam_path
  workers_additional_policies = [
    // ALB Ingress
    aws_iam_policy.load_balancer.arn
  ]
  permissions_boundary = var.iam_permissions_boundary_policy
}
