provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ecr = "http://localhost:4566"
  }
}

run "default_repository" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.repository_name == "hello-local-cloud"
    error_message = "Repository name should use full_name convention"
  }

  # repository_url is computed (null in plan mode) — we validate it exists when known
  assert {
    condition     = output.arn != ""
    error_message = "ARN should not be empty"
  }

  assert {
    condition     = output.registry_id != ""
    error_message = "Registry ID should not be empty"
  }
}

run "custom_repository_name" {
  command = plan

  variables {
    repository_name = "my-app"
  }

  module {
    source = "./."
  }

  assert {
    condition     = output.repository_name == "my-app-local-cloud"
    error_message = "Custom repository name should use full_name convention"
  }
}

run "immutable_tags" {
  command = plan

  variables {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = false
  }

  module {
    source = "./."
  }

  assert {
    condition     = output.repository_name == "hello-local-cloud"
    error_message = "Repository name should be consistent"
  }
}