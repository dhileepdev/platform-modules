mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    }
  }
}

run "two_az_defaults" {
  command = plan
  variables {
    name_prefix        = "demo"
    vpc_cidr           = "10.0.0.0/16"
    az_count           = 2
    single_nat_gateway = true
  }
  assert {
    condition     = output.vpc_cidr == "10.0.0.0/16"
    error_message = "vpc_cidr must pass through unchanged"
  }
  assert {
    condition     = length(output.private_subnet_ids) == 2 && length(output.public_subnet_ids) == 2
    error_message = "az_count subnets expected per tier"
  }
  assert {
    condition     = length(output.nat_gateway_ids) == 1
    error_message = "single_nat_gateway must create one NAT"
  }
}

run "one_az_tight_cidr" {
  command = plan
  variables {
    name_prefix        = "tight"
    vpc_cidr           = "10.42.0.0/21"
    az_count           = 1
    single_nat_gateway = false
  }
  assert {
    condition     = length(output.private_subnet_ids) == 1
    error_message = "one AZ yields one private subnet"
  }
}

run "rejects_bad_cidr" {
  command = plan
  variables {
    name_prefix = "bad"
    vpc_cidr    = "10.0.0.0/33"
  }
  expect_failures = [var.vpc_cidr]
}
