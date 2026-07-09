terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "table_name" {
  type    = string
  default = "local-cloud-state"
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    managed_by  = "opentofu"
    environment = "local"
  }
}

output "table_name" { value = aws_dynamodb_table.this.name }
output "table_id" { value = aws_dynamodb_table.this.id }
