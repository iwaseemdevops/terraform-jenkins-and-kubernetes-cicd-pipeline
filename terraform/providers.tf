# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a recent version
    }
  }
  # We will add the backend configuration later after creating the S3 bucket
}

provider "aws" {
  region = "ap-south-1" 
}