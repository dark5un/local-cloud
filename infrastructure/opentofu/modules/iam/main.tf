terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "role_name" {
  type    = string
  default = "local-cloud-role"
}

resource "aws_iam_role" "this" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = {
    managed_by  = "opentofu"
    environment = "local"
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.role_name}-policy"
  description = "Local cloud policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"], Resource = "*" },
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

output "role_name" { value = aws_iam_role.this.name }
output "role_arn" { value = aws_iam_role.this.arn }
output "policy_arn" { value = aws_iam_policy.this.arn }
