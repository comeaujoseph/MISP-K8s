terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
    required_version = ">= 0.14.9"

    backend "s3" {
        bucket = "terraform.batd.cudaops.com"
        key = "misp"
        region = "us-east-2"
    }
}

provider "aws" {
    profile = "svc-kubernetes-dev"
    region  = "us-east-2"
}