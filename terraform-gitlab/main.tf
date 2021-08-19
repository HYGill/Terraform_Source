locals {
  region       = "ap-northeast-2"
}

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 3.53.0"
        }
    }
    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region  = local.region
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  # 워커노드가 생성되면 DNS 호스트 이름을 받게 설정하여 DNS 통신이 가능하게끔 설정
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks_vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = "${aws_vpc.eks_vpc.id}"

	tags = { 
		Name = "eks_igw"
	}
}

resource "aws_subnet" "eks_public_subnet" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.0.0/19"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "eks_public_subnet"
  }
}

resource "aws_route_table" "eks_public_rt" {
	vpc_id = "${aws_vpc.eks_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id
    }

	tags = {
		Name = "eks_public_route"
	}
}

resource "aws_security_group" "public_gitlab_group" {
    vpc_id = "${aws_vpc.eks_vpc.id}"
    name        = var.public_gitlab_group
	description = "public gitlab Security Group"

	tags = { 
		Name = var.public_gitlab_group
	}
}

resource "aws_security_group_rule" "public_gitlab_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["내 PC IP"]
  security_group_id = "${aws_security_group.public_gitlab_group.id}"
}
 
resource "aws_security_group_rule" "public_gitlab_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_gitlab_group.id}"
}

resource "aws_security_group_rule" "public_gitlab" {
  type              = "ingress"
  from_port         = 8899
  to_port           = 8899
  protocol          = "TCP"
  cidr_blocks       = ["내 PC IP"]
  security_group_id = "${aws_security_group.public_gitlab_group.id}"
}

resource "aws_instance" "public_gitlab_instance" {
  ami = "ami-0e1e385b0a934254a"
  availability_zone = "${aws_subnet.eks_public_subnet.availability_zone}"
  instance_type = "t2.medium"
  key_name = "liiv_agile"
  vpc_security_group_ids = [
    "${aws_security_group.public_gitlab_group.id}"
  ]
  subnet_id = "${aws_subnet.eks_public_subnet.id}"
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }

  connection {
    host        = "${aws_instance.public_gitlab_instance.public_ip}"
    user        = "ec2-user"
    type        = "ssh"
    private_key = "${file("~~파일위차.pem")}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
      "curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash",
      "sudo EXTERNAL_URL='${aws_instance.public_gitlab_instance.public_ip}:8899' yum install -y gitlab-ce",
      "sudo gitlab-ctl start"
    ]
  }
}