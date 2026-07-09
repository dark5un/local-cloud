provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

run "create_bucket" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.bucket_name == "local-cloud-artifacts"
    error_message = "Bucket name mismatch"
  }

  assert {
    condition     = output.versioning_enabled == "Enabled"
    error_message = "Versioning should be enabled"
  }
}

run "custom_bucket_name" {
  command = plan

  variables {
    bucket_name = "my-custom-bucket"
  }

  module {
    source = "./."
  }

  assert {
    condition     = output.bucket_name == "my-custom-bucket"
    error_message = "Custom bucket name not applied"
  }
}
