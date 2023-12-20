terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

  }
}




provider "aws" {
  region = "us-east-1"

}
provider "github" {
  token = "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"

}