
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project     = "ApplicationSupportTicketingSystem"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
