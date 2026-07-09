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
}
