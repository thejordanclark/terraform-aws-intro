terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.3.0"
}

provider "random" {
}

resource "random_integer" "number" {
  min     = 1
  max     = 100
}
