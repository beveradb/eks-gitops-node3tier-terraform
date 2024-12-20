terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # This S3 bucket and DynamoDB table must already exist before Terraform can use them to store state and track locks
  # If you're attempting to use this in a completely clean/empty AWS account or have never provisioned these before,
  # Use the ./remote-tfstate terraform module (which uses local state file) to create them first!
  backend "s3" {
    bucket         = "beveradb-toptal-terraform-state" # Backend config: set this to your chosen TF state bucket name
    region         = "us-east-1" # Backend config: set this to the region your DynamoDB lock table is in
    dynamodb_table = "terraform-state-locks"
    key            = "terraform.tfstate"
    encrypt        = true
  }
}

# Configure the AWS Provider, with default tags to apply to all resources
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
    }
  }
}

module "vpc" {
  source                  = "./vpc"
  name                    = var.name
  environment             = var.environment
  cidr                    = var.cidr
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  database_subnets        = var.database_subnets
  availability_zones      = var.availability_zones
  flow_log_retention_days = var.flow_log_retention_days
}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  k8s_version     = var.k8s_version
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

provider "helm" {
  kubernetes {
    host                   = module.eks.kubernetes_params.host
    token                  = module.eks.kubernetes_params.token
    cluster_ca_certificate = module.eks.kubernetes_params.cluster_ca_certificate
  }
}

module "ingress" {
  source     = "./ingress"
  region     = var.region
  vpc_id     = module.vpc.id
  cluster_id = module.eks.cluster_id
}

module "ssl" {
  source     = "./ssl"
  app_domain = "beveridge.uk"
}

module "fluxcd" {
  source = "./fluxcd"
}

module "sealedsecrets" {
  source = "./sealedsecrets"
}

module "ecr" {
  source = "./ecr"
  name   = var.name
}

module "rds" {
  source              = "./rds"
  name                = var.name
  region              = var.region
  vpc_id              = module.vpc.id
  database_subnet_ids = module.vpc.database_subnets[*].id
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_public_subnets" {
  value = [
  for subnet in module.vpc.public_subnets : subnet.arn
  ]
}

output "vpc_private_subnets" {
  value = [
  for subnet in module.vpc.private_subnets : subnet.arn
  ]
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "app_url" {
  value = "https://${var.app_domain}"
}

output "ecr_access_key_id" {
  value = module.ecr.ecr_access_key_id
}

output "ecr_repo_name" {
  value = module.ecr.ecr_repo_name
}

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "db_instance_address" {
  value = module.rds.db_instance_address
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  value = module.rds.db_instance_port
}
