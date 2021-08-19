variable "vpc_name" {
  description = "name of VPC"
  type = string
  default     = "default_vpc"
}

variable "igw_name" {
    description = "name of Internet Gateway"
    type = string
    default = "default_igw"
}

variable "public_subnet_name" {
    description = "name of Subnet"
    type = string
    default = "default_subnet"
}

variable "private_subnet_name" {
    description = "name of Subnet"
    type = string
    default = "default_subnet"
}

variable "private_subnet2_name" {
    description = "name of Subnet 2"
    type = string
    default = "default_subnet2"
}

variable "private_group" {
  description = "name of private Security Group"
  type = string
  default     = "default_group"
}

variable "public_route_name" {
  description = "name of public route table"
  type = string
  default     = "default_rt"
}

variable "private_route_name" {
  description = "name of private route table"
  type = string
  default     = "default_rt"
}

variable "private_route_name2" {
  description = "name of private route table"
  type = string
  default     = "default_rt"
}


variable "nat_gateway_name" {
    description = "name of Nat Gateway"
    type = string
    default = "default_nat"
}

variable "instance_name" {
    description = "name of instance"
    type = string
    default = "default_instance"
}