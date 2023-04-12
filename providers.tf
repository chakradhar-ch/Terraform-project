terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "s3-bucket-vc"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
