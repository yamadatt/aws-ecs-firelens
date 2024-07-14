#############################
# Terraform configuration
#############################
terraform {
  required_version = ">=1.8.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.57.0"
    }
  }
}

#############################
# Provider
#############################
provider "aws" {
  region = "ap-northeast-1"
}