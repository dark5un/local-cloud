# Real AWS deployment template
# Copy to environments/staging or environments/prod
#
# Usage:
#   tofu init
#   tofu plan   # review changes
#   tofu apply  # deploy

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35"
    }
  }

  # Uncomment and configure for team deployments:
  # backend "s3" {
  #   bucket         = "local-cloud-terraform-state"
  #   key            = "environments/staging/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "local-cloud-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  # AWS credentials sourced from:
  # 1. AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env vars
  # 2. ~/.aws/credentials (default profile)
  # 3. IAM instance role (EC2)
  # No hardcoded credentials — never commit secrets
}

# Kubernetes provider only needed if deploying to EKS
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "local-cloud"
}

# Reuse the same modules — they are provider-agnostic
module "network" {
  source = "../../modules/network"
}

module "storage" {
  source = "../../modules/storage"

  tags = {
    Environment = var.environment
    vpc_id      = module.network.vpc_id
  }
}

module "iam" {
  source = "../../modules/iam"
}

module "dynamodb" {
  source = "../../modules/dynamodb"
}

module "ecs" {
  source    = "../../modules/ecs"
  subnet_id = module.network.subnet_id
}

output "vpc_id"     { value = module.network.vpc_id }
output "bucket_name" { value = module.storage.bucket_name }
output "role_name"  { value = module.iam.role_name }
output "table_name" { value = module.dynamodb.table_name }
output "ecs_cluster" { value = module.ecs.cluster_name }