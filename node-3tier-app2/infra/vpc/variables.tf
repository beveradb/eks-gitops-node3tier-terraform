variable "name" {
  description = "Name of the VPC. Used as a prefix in resource names and tags"
}

variable "environment" {
  description = "Environment this VPC is part of. Used in prefix for resource names and tags"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "database_subnets" {
  description = "List of database subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC flow logs (in days)"
}
