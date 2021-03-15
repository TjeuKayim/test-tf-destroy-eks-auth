variable "aws_region" {
  type = string
}

variable "cluster_name" {
  default = "foo-bar"
}

variable "environment" {
  default = "dev"
}

variable "iam_prefix" {
  description = "All IAM policies will be created on this path"
  type        = string
}
