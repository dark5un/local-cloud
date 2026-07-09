provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ecs       = "http://localhost:4566"
    ec2       = "http://localhost:4566"
    iam       = "http://localhost:4566"
    sts       = "http://localhost:4566"
    s3        = "http://localhost:4566"
    elasticloadbalancing = "http://localhost:4566"
  }
}

run "create_service" {
  command = apply

  module {
    source = "./."
  }

  assert {
    condition     = output.cluster_name == "local-cloud"
    error_message = "Cluster name mismatch"
  }

  assert {
    condition     = output.service_name == "web"
    error_message = "Service name mismatch"
  }

  assert {
    condition     = output.desired_count == 1
    error_message = "Desired count should be 1"
  }
}
