terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region         = "us-west-2"
    key            = "terraform.labs.tfstate"
    dynamodb_table = "terraform-state-lock"
  }
  required_version = ">= 1.3.0"
}

provider "random" {
}

provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Name = "Terraform-Labs"
      Environment = local.environment
    }
  }
}

locals {
  region = var.region
  environment = "Lab"
  instance_ami = "ami-03d5c68bab01f3496"  # ubuntu OS
}
