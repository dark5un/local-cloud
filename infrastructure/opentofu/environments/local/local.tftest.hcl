run "local_environment" {
  command = plan

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC should be created"
  }

  assert {
    condition     = output.bucket_name == "local-cloud-artifacts"
    error_message = "S3 bucket should exist"
  }

  assert {
    condition     = output.ecs_cluster == "local-cloud"
    error_message = "ECS cluster should be named local-cloud"
  }

  assert {
    condition     = output.ecr_repository == "hello-local-cloud"
    error_message = "ECR repository should use full_name convention"
  }
}