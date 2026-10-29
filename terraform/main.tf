data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_name}-backups-${random_id.suffix.hex}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = "10.60.0.0/16"

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnets = [
    "10.60.1.0/24",
    "10.60.2.0/24"
  ]

  private_subnets = [
    "10.60.11.0/24",
    "10.60.12.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.project_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = [var.my_ip_cidr]

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    dr = {
      name           = "${var.project_name}-nodes"
      instance_types = [var.node_instance_type]

      min_size     = 2
      desired_size = 2
      max_size     = 3

      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_s3_bucket" "backups" {
  bucket        = local.bucket_name
  force_destroy = false

  tags = {
    Name    = "${var.project_name}-backups"
    Purpose = "DisasterRecovery"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "bucket_name" {
  value = aws_s3_bucket.backups.bucket
}

output "region" {
  value = var.aws_region
}