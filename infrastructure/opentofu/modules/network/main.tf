terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "local-cloud-vpc"
    managed_by  = "opentofu"
    environment = "local"
  })
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = merge(var.tags, {
    Name        = "local-cloud-public"
    managed_by  = "opentofu"
    environment = "local"
  })
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "vpc_dns_support" {
  value = aws_vpc.this.enable_dns_support
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "subnet_cidr" {
  value = aws_subnet.public.cidr_block
}
