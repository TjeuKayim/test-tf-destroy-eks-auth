variable "aws_region" {
  type = string
}

variable "cluster_name" {
  default = "foo-bar"
}

variable "environment" {
  default = "dev"
}

variable "iam_path" {
  description = "All IAM policies will be created on this path"
  type        = string
}

variable "iam_permissions_boundary_policy" {
  description = "ARN of policy to use as a permissions boundary for roles managed by Terraform"
  type        = string
}

variable "hostname" {
  description = "DNS hostname, like `abc.example.com`"
  type        = string
}
