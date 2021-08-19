variable "vpc_name" {
  description = "name of VPC"
  type = string
  default     = "default_vpc"
}

variable "igw_name" {
  description = "name of Internet Gateway"
  type = string
  default     = "default_igw"
}

variable "public_subnet_name" {
  description = "name of public subnet"
  type = string
  default     = "default_subnet"
}

variable "private_subnet_name" {
  description = "name of private subnet"
  type = string
  default     = "default_subnet"
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

variable "public_group" {
  description = "name of public Security Group"
  type = string
  default     = "default_group"
}

variable "private_group" {
  description = "name of private Security Group"
  type = string
  default     = "default_group"
}

variable "public_instance" {
  description = "name of public_instance"
  type = string
  default     = "default_instance"
}

variable "private_instance" {
  description = "name of private_instance"
  type = string
  default     = "default_instance"
}