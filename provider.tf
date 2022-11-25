terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
#  access_key = var.aws_access_key
#  secret_key = var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket = "tf-state-916"
    key    = "assignment-c7/terraform.tfstate"
  }
}
