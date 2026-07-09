provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    dynamodb = "http://localhost:4566"
  }
}

run "create_table" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.table_name == "local-cloud-state"
    error_message = "Table name mismatch"
  }

  assert {
    condition     = output.table_id != ""
    error_message = "Table ID should be set"
  }
}
