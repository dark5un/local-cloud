terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "local-cloud"
}

variable "service_name" {
  type    = string
  default = "web"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "task_image" {
  type    = string
  default = "localhost:5000/hello:latest"
}

variable "subnet_id" {
  type    = string
  default = ""
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  tags = {
    managed_by  = "opentofu"
    environment = "local"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::000000000000:role/local-cloud-role"
  task_role_arn            = "arn:aws:iam::000000000000:role/local-cloud-role"

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.task_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.subnet_id != "" ? [var.subnet_id] : ["subnet-placeholder"]
  }
}

output "cluster_name" { value = aws_ecs_cluster.this.name }
output "service_name" { value = aws_ecs_service.this.name }
output "desired_count" { value = aws_ecs_service.this.desired_count }
output "task_definition_arn" { value = aws_ecs_task_definition.this.arn }
