resource "aws_vpc" "terraform_vpc" {
	cidr_block = "10.0.0.0/24"

    tags = {
        Name = var.vpc_name
    }
}

/*
* AWS에서 VPC를 생성하면 자동으로 route table이 하나 생긴다. 
* 이는 Terraform으로 직접 생성하는 것이 아니므로 
* aws_default_route_table는 route table을 만들지 않고 
* VPC가 만든 기본 route table을 가져와서 Terraform이 관리할 수 있게 한다.
*/
resource "aws_default_route_table" "default_rt" {
	default_route_table_id = "${aws_vpc.terraform_vpc.default_route_table_id}"

	tags = {
		Name = "default_rt"
	}
}

# vpc와 internet gateway 연결
resource "aws_internet_gateway" "terraform_igw" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	tags = { 
		Name = var.igw_name
	}
}

# subnet 생성
resource "aws_subnet" "terraform_public_subnet" {
	vpc_id            = "${aws_vpc.terraform_vpc.id}"
	cidr_block        = "10.0.0.0/25"
	availability_zone = "ap-northeast-2a"

	tags = { 
		Name = var.public_subnet_name
	}
}

resource "aws_subnet" "terraform_private_subnet" {
	vpc_id            = "${aws_vpc.terraform_vpc.id}"
	cidr_block        = "10.0.0.128/26"
	availability_zone = "ap-northeast-2a"

	tags = { 
		Name = var.private_subnet_name
	}
}

# route table 생성
resource "aws_route_table" "terraform_public_rt" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"

	tags = {
		Name = var.public_route_name
	}
}

resource "aws_route_table" "terraform_private_rt" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	
	tags = {
		Name = var.private_route_name
	}
}

# route table과 subnet 연결
resource "aws_route_table_association" "terraform_public_association" {
	subnet_id      = "${aws_subnet.terraform_public_subnet.id}"
	route_table_id = "${aws_route_table.terraform_public_rt.id}"
}

resource "aws_route_table_association" "terraform_private_association" {
	subnet_id      = "${aws_subnet.terraform_private_subnet.id}"
	route_table_id = "${aws_route_table.terraform_private_rt.id}"
}

# 보안그룹 생성
resource "aws_security_group" "public_group" {
	vpc_id      = "${aws_vpc.terraform_vpc.id}"
	name        = var.public_group
	description = "public ec2 Security Group"

	tags = { 
		Name = var.public_group
	}
}

resource "aws_security_group_rule" "public_group_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["내 PC IP"]
  security_group_id = "${aws_security_group.public_group.id}"

}

resource "aws_instance" "public_instance" {
  ami = "ami-0e1e385b0a934254a"
  availability_zone = "${aws_subnet.terraform_public_subnet.availability_zone}"
  instance_type = "t2.micro"
  key_name = "keyname"
  vpc_security_group_ids = [
    "${aws_security_group.public_group.id}"
  ]
  subnet_id = "${aws_subnet.terraform_public_subnet.id}"
  associate_public_ip_address = true

  tags = {
    Name = var.public_instance
  }
}

resource "aws_security_group" "private_group" {
	vpc_id      = "${aws_vpc.terraform_vpc.id}"
	name        = var.private_group
	description = "private ec2 Security Group"

	tags = { 
		Name = var.private_group
	}
}

resource "aws_security_group_rule" "private_group_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["52.78.107.146/32"]
  security_group_id = "${aws_security_group.private_group.id}"
}

resource "aws_security_group_rule" "private_group_rule_icmp" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["52.78.107.146/32"]
  security_group_id = "${aws_security_group.private_group.id}"
}

resource "aws_instance" "private_instance" {
  ami = "ami-0e1e385b0a934254a"
  availability_zone = "${aws_subnet.terraform_private_subnet.availability_zone}"
  instance_type = "t2.micro"
  key_name = "keyName"
  vpc_security_group_ids = [
    "${aws_security_group.private_group.id}"
  ]
  subnet_id = "${aws_subnet.terraform_private_subnet.id}"
  associate_public_ip_address = false

  tags = {
    Name = var.private_instance
  }
}