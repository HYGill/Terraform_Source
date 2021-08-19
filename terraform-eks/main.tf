locals {
  cluster_name = "eks-cluster"
  region       = "ap-northeast-2"
}

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 3.40.0"
        }
    }
    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region  = local.region
}

resource "aws_key_pair" "public_bastion" {
	  key_name = "liiv_agile_eks"
    public_key = "${file("~~파일위치.pub")}"
}

resource "aws_vpc" "eks_vpc" {
	cidr_block = "10.0.0.0/16"

    # 워커노드가 생성되면 DNS 호스트 이름을 받게 설정하여 DNS 통신이 가능하게끔 설정
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = var.vpc_name
    }
}

resource "aws_default_route_table" "default_rt" {
	default_route_table_id = "${aws_vpc.eks_vpc.default_route_table_id}"

	tags = {
		Name = "default_rt"
	}
}

# vpc와 internet gateway 연결
resource "aws_internet_gateway" "eks_igw" {
	vpc_id = "${aws_vpc.eks_vpc.id}"

	tags = { 
		Name = var.igw_name
	}
}

resource "aws_subnet" "eks_public_subnet" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.0.0/19"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "eks_private_subnet" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.224.0/21"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_subnet" "eks_private_subnet2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.249.0/25"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = var.private_subnet2_name
  }
}


# nat gateway에 연결할 eip 설정
resource "aws_eip" "eip" {
  vpc = true
}

# Create Nat Gateway
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${aws_subnet.eks_public_subnet.id}"

  tags = {
    Name = var.nat_gateway_name
  }
}

# route table 생성
resource "aws_route_table" "eks_public_rt" {
	vpc_id = "${aws_vpc.eks_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id
    }

	tags = {
		Name = var.public_route_name
	}
}

resource "aws_route_table" "eks_private_rt" {
	vpc_id = "${aws_vpc.eks_vpc.id}"

    # 0.0.0.0/0을 목적지로 하는 Packet을 NAT Gateway로 전달
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.eks_nat.id
    }
	
	tags = {
		Name = var.private_route_name
	}
}

resource "aws_route_table" "eks_private_rt2" {
	vpc_id = "${aws_vpc.eks_vpc.id}"

    # 0.0.0.0/0을 목적지로 하는 Packet을 NAT Gateway로 전달
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.eks_nat.id
    }
	
	tags = {
		Name = var.private_route_name2
	}
}

# route table과 subnet 연결
resource "aws_route_table_association" "eks_public_association" {
	subnet_id      = "${aws_subnet.eks_public_subnet.id}"
	route_table_id = "${aws_route_table.eks_public_rt.id}"
}

resource "aws_route_table_association" "eks_private_association" {
	subnet_id      = "${aws_subnet.eks_private_subnet.id}"
	route_table_id = "${aws_route_table.eks_private_rt.id}"
}

resource "aws_route_table_association" "eks_private_association2" {
	subnet_id      = "${aws_subnet.eks_private_subnet2.id}"
	route_table_id = "${aws_route_table.eks_private_rt2.id}"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  vpc_id      = "${aws_vpc.eks_vpc.id}"
  subnets     = ["${aws_subnet.eks_private_subnet.id}", "${aws_subnet.eks_private_subnet2.id}"]
  cluster_version = "1.20"
  cluster_endpoint_public_access_cidrs = ["~~내 PC IP", "${aws_nat_gateway.eks_nat.public_ip}/32"]

  node_groups = {
      eks_nodes = {
          desired_capacity = 2
          max_capacity     = 5
          min_capacity     = 2
          key_name         = aws_key_pair.public_bastion.key_name
          instance_types = ["t3.small"]
      }
    }
  manage_aws_auth = false
}