variable "name" {
  description = "Name of this EKS cluster. Used as a prefix in resource names and tags"
}

variable "environment" {
  description = "Environment this cluster is part of. Used in prefix for resource names and tags"
}

variable "k8s_version" {
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version."
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to match number of AZs"
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to match number of AZs"
}
