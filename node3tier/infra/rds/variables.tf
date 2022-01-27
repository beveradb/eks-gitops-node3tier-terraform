variable "name" {
  type        = string
  description = "The (alphanumeric) name of the service this DB is for"
}

variable "region" {
  description = "AWS region in which resources are created"
}

variable "vpc_id" {
  description = "ID of the VPC the DB is in"
}

variable "database_subnet_ids" {
  description = "IDs of subnets for the database to be created in"
}
