# Test destroy EKS auth

Reproduce issue <https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1162>.

This demo has a PVC to check if it the EBS volume is cleaned up correctly.

Experiment with Terraform v0.13.5:

- `terraform apply` success
- `terraform destroy` success
