mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
}

run "small_node_group" {
  command = plan
  variables {
    name_prefix            = "demo"
    cluster_version        = "1.33"
    subnet_ids             = ["subnet-a", "subnet-b"]
    node_instance_types    = ["t3.small"]
    node_desired_size      = 2
    endpoint_public_access = true
    public_access_cidrs    = ["203.0.113.10/32"]
  }
  assert {
    condition     = output.node_group_name == "demo-nodes"
    error_message = "node group naming contract"
  }
}

run "public_endpoint_requires_cidrs" {
  command = plan
  variables {
    name_prefix            = "demo"
    cluster_version        = "1.33"
    subnet_ids             = ["subnet-a"]
    endpoint_public_access = true
    public_access_cidrs    = []
  }
  expect_failures = [var.public_access_cidrs]
}
