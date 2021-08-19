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

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::{useId}:user/developer"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}


resource "aws_iam_role" "developer-role" {
    name               = var.role_name
    description        = "developer role"
    path               = "/"
    max_session_duration = 43200
    assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "developer-policy" {
    name   = var.policy_name
    role   = aws_iam_role.developer-role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceAttribute",
                "ec2:CreateKeyPair",
                "ec2:CreateVpc",
                "ec2:AttachInternetGateway",
                "ec2:DescribeVpcAttribute",
                "ec2:AssociateRouteTable",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVolumeStatus",
                "ec2:StartInstances",
                "ec2:CreateRoute",
                "ec2:CreateInternetGateway",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:CreateSecurityGroup",
                "ec2:DescribeVolumes",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInstanceStatus",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:TerminateInstances",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:CreateRouteTable",
                "ec2:RunInstances",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeSecurityGroups",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeImages",
                "ec2:DescribeVpcs",
                "ec2:DescribeInstanceTypes",
                "ec2:CreateSubnet",
                "ec2:DescribeSubnets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "developer" {
    name = var.instance_profile_name
    role = aws_iam_role.developer-role.name
}

output "developer_iam_role_arn" {
  description = "ARN of developer IAM role"
  value = aws_iam_role.developer-role.arn
}