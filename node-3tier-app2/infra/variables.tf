variable "name" {
  description = "Name of the app stack"
  default     = "node3tier"
}

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

variable "availability_zones" {
  description = "Comma-separated list of availability zones. If edited, you'll need to edit private_subnets and public_subnets too"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to match number of AZs"
  default     = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to match number of AZs"
  default     = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}

variable "kubeconfig_path" {
  description = "Directory to write kubectl config file. Note, this will overwrite any existing config file in this path!"
  default     = "~/.kube"
}

variable "k8s_version" {
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version."
  default     = ""
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC flow logs (in days)"
  default     = 30
}

variable "additional_tags" {
  default     = {
    "" = ""
  }
  description = "Additional resource tags"
  type        = map(string)
}
