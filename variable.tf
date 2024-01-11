terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "sg-terraform-demo"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id  
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_sg_demo" {
  type = "zip"

  source_dir  = "${path.module}/sg-demo"
  output_path = "${path.module}/sg-demo.zip"
}

resource "aws_s3_object" "lambda_sg_demo" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "sg-demo.zip"
  source = data.archive_file.lambda_sg_demo.output_path

  etag = filemd5(data.archive_file.lambda_sg_demo.output_path)
}