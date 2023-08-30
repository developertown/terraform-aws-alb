include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../..//."
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id                    = "vpc-1234567890"
    public_subnets            = ["subnet-1234567890", "subnet-1234567890"]
    default_security_group_id = "sg-1234567890"
  }
}

inputs = {
  name       = "test-example"
  vpc_id     = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.public_subnets

  region      = "us-east-2"
  environment = "test"
  tags = {
    "CreatedBy" = "Terraform"
    "Company"   = "DeveloperTown"
  }
}
