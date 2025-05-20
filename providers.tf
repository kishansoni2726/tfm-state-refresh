provider "aws" {
  region     = var.region
}


terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-aws-kishan1"
    key            = "bookstore/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}



