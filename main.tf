terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  project_name = "skillboost-analytics"
  environment  = "dev"
  owner        = "Charles Adu Nkansah"
  repo         = "https://github.com/yourusername/skillboost-analytics-iac"
}

