terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region  = "ap-northeast-2"
}

resource "aws_iam_user" "developer-user" {
  name = var.developer-user
}

resource "aws_iam_user_policy" "develper-policy" {
  name  = "assume-policy"
  user  = aws_iam_user.developer-user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}