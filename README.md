# Test destroy EKS auth

Reproduce issue <https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1162>.

This demo has a PVC to check if it the EBS volume is cleaned up correctly.

Experiment with Terraform v0.13.5:

- `terraform apply` success
- `terraform destroy` success

Experiment with Terraform v0.14.0:

- `terraform apply`
- `terraform destroy` success

Experiment with Terraform v0.14.3:

- `terraform apply` success
- `terraform destroy` success

Same for commit 5bbd1d41f0f68cba07d774d86e6a7754a23750e3 + v0.14.3.
