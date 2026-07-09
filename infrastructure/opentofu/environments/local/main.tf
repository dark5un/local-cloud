terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3        = "http://localhost:4566"
    ec2       = "http://localhost:4566"
    iam       = "http://localhost:4566"
    sts       = "http://localhost:4566"
    ecs       = "http://localhost:4566"
    dynamodb  = "http://localhost:4566"
    elasticloadbalancing = "http://localhost:4566"
  }
}

module "network" {
  source = "../../modules/network"
}

module "storage" {
  source = "../../modules/storage"

  tags = {
    vpc_id = module.network.vpc_id
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

output "vpc_id" { value = module.network.vpc_id }
output "bucket_name" { value = module.storage.bucket_name }
output "role_name" { value = module.iam.role_name }
output "table_name" { value = module.dynamodb.table_name }
output "ecs_cluster" { value = module.ecs.cluster_name }