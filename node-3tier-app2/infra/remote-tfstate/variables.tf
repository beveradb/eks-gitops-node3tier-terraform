
variable "environment" {
  description = "Name of the environment, e.g. prod. Added to tags for all resources"
  default     = "prod"
}

variable "owner" {
  description = "Owner of these resources, e.g. platform. Added to tags for all resources"
  default     = "platform"
}

variable "region" {
  description = "AWS region in which resources are created. If edited, you'll need to edit availability_zones too"
  default     = "us-east-1"
}

variable "terraform_state_bucket_name" {
  description = "Name of the S3 bucket containing Terraform state for this AWS account"
  default     = "beveradb-toptal-terraform-state"
}

variable "terraform_state_lock_dynamodb_name" {
  description = "Name of the DynamoDB table containing Terraform state locks for this AWS account"
  default     = "terraform-state-locks"
}
