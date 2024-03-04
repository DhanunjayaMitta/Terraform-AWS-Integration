#
# Terraform and Providers setup
#

terraform {
  required_version = ">= 1.1.5"
  backend "s3" {
  }

}

provider "aws" {
  region  = var.region
  version = "4.8.0"
  default_tags {
    tags = {
      OrgScope        = "Not Set"
      FunctionalScope = "Not Set"
      Environment     = "Not Set"
      ModuleName      = "Not Set"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "useast1"
  version = "4.8.0"
}

terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.21.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "grafana" {
  url  = var.grafana_workspace_url
  auth = var.grafana_workspace_APIkey
}

locals {
  stage                      = var.environment
  in_default_workspace       = terraform.workspace == "default"
  workspace_prefix           = local.in_default_workspace ? "" : terraform.workspace
  count_in_default_workspace = local.in_default_workspace ? 1 : 0
  in_production              = var.stage == "prd"
  in_development             = var.stage == "dev"
  in_integration             = var.stage == "int"
  in_workspaces              = !local.in_default_workspace
  count_in_production        = local.in_production ? 1 : 0
  workspace_arn_prefix       = terraform.workspace != "default" && var.stage == "dev" ? "*" : ""
  project_stage_pattern      = "${local.workspace_arn_prefix}${var.project}-${var.stage}*"
  account_id                 = data.aws_caller_identity.current.account_id
  private_subnet_ids_gen_2   = var.private_subnet_ids_gen_2[local.stage]
}

data "terraform_remote_state" "cap" {
  backend = "s3"
  config = {
    bucket = "cap-${var.stage}-terraform-backend"
    key    = "analytics-vpc-${var.region}/cap/cap.tfstate"
    region = var.region
  }
}

data "aws_caller_identity" "current" {}

