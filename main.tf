terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Use a backend if working in a team or using remote state
  # backend "s3" {
  #   bucket = "skillboost-tf-state"
  #   key    = "analytics/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Project metadata (for context)
locals {
  project_name = "skillboost-analytics"
  environment  = "dev"
  owner        = "Charles Adu Nkansah"
  repo         = "https://github.com/yourusername/skillboost-analytics-iac"
}

