terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "repository_name" {
  type    = string
  default = "hello"
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  full_name = "${var.repository_name}-local-cloud"
}

resource "aws_ecr_repository" "this" {
  name = local.full_name

  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(var.tags, {
    managed_by  = "opentofu"
    environment = "local"
  })
}

output "repository_name" {
  value = aws_ecr_repository.this.name
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "arn" {
  value = aws_ecr_repository.this.arn
}

output "registry_id" {
  value = aws_ecr_repository.this.registry_id
}