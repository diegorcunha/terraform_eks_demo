#
# Provider Configuration
#

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/Users/tf_user/.aws/credentials"
  profile                 = "default"
}

data "aws_availability_zones" "available" {}