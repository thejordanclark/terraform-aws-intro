terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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

resource "random_integer" "number" {
  min     = 1
  max     = 100
}
