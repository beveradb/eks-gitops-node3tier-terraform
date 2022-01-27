data "aws_vpc" "main" {
  id = var.vpc_id
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.name}-db-sg"
  description = "${var.name} PostgreSQL database security group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.main.cidr_block
    },
  ]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "${var.name}-postgres"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t2.micro"

  allocated_storage = 20

  name                   = var.name
  username               = "${var.name}dbuser"
  create_random_password = true
  random_password_length = 12
  port                   = 5432

  multi_az               = true
  subnet_ids             = var.database_subnet_ids
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"

  backup_window           = "03:00-06:00"
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  create_monitoring_role      = true
  monitoring_interval         = 60
  monitoring_role_name        = "${var.name}-postgres-monitoring-role"
  monitoring_role_description = "${var.name} postgres DB monitoring role"
}
