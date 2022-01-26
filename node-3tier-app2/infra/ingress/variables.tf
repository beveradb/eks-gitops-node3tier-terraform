
variable "region" {
  description = "AWS region in which resources are created"
}

variable "vpc_id" {
  description = "ID of the VPC the cluster is in"
}

variable "cluster_id" {
  description = "ID of the cluster where the ingress controller should be attached"
}
