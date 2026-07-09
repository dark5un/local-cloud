provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

run "create_role" {
  command = apply

  module {
    source = "./."
  }

  assert {
    condition     = output.role_name == "local-cloud-role"
    error_message = "Role name mismatch"
  }

  assert {
    condition     = output.policy_arn != ""
    error_message = "Policy ARN should be set"
  }
}
