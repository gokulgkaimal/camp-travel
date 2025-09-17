variable "project_name" {
  type    = string
  default = "camp-travel"
}

variable "region" {
  type    = string
  default = "ap-south-1" # Mumbai
}

variable "aws_profile" {
  type    = string
  default = "myprofile"
}

# VPC & subnets (public only to avoid NAT)
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_a_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "public_b_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

# EKS
variable "eks_version" {
  type    = string
  default = "1.29"
}

variable "node_instance" {
  type    = string
  default = "t3.medium"
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

# Tools EC2
variable "tools_instance_type" {
  type    = string
  default = "t2.large"
}

variable "key_name" {
  type    = string
  default = "my-ec2-key" # replace with your actual Key Pair name
}


