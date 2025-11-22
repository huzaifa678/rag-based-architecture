terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

  required_version = ">= 1.6.0"
}

terraform {
  backend "s3" {
    bucket = "rag-terraform-s3-2345"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}