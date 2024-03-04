terraform {
  required_version = ">= 1.1.5"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.20"  # Update this line
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "newrelic" {
  region = "EU"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  api_key = var.NEW_RELIC_API_KEY
  # Valid regions are US and EU
}


provider "aws" {
  region = var.region
}