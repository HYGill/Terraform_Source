variable "role_name" {
  description = "name of role"
  type = string
  default = "default_role"
}

variable "policy_name" {
  description = "name of policy"
  type = string
  default = "default_policy"
}

variable "instance_profile_name" {
  description = "name of instance profile"
  type = string
  default = "default_instance_profile"
}