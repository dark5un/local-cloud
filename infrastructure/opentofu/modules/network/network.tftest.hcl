provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

run "create_vpc" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.vpc_cidr == "10.0.0.0/16"
    error_message = "VPC CIDR mismatch"
  }

  assert {
    condition     = output.vpc_dns_support == true
    error_message = "DNS support should be enabled"
  }

  assert {
    condition     = output.subnet_cidr == "10.0.1.0/24"
    error_message = "Subnet CIDR mismatch"
  }
}
