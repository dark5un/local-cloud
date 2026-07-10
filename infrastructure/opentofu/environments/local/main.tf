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
    ecr       = "http://localhost:4566"
    elasticloadbalancing = "http://localhost:4566"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
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

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "hello"

  tags = {
    vpc_id = module.network.vpc_id
  }
}

output "vpc_id" { value = module.network.vpc_id }
output "bucket_name" { value = module.storage.bucket_name }
output "role_name" { value = module.iam.role_name }
output "table_name" { value = module.dynamodb.table_name }
output "ecs_cluster" { value = module.ecs.cluster_name }
output "ecr_repository" { value = module.ecr.repository_name }
output "ecr_repository_url" { value = module.ecr.repository_url }

module "k8s" {
  source = "../../modules/k8s"

  app_name = "hello-local-cloud"
  app_image = "nginx:alpine"
  app_port  = 80
  replicas  = 2
}

output "k8s_namespace" { value = module.k8s.namespace }
output "k8s_deployment" { value = module.k8s.deployment_name }
output "k8s_service" { value = module.k8s.service_name }