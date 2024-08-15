variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "my-eks-cluster"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "node_group_instance_type" {
  type = string
  default = "t3.medium"
}

variable "node_group_min_size" {
  type = number
  default = 2
}

variable "node_group_max_size" {
  type = number
  default = 4
}

# Optional variables for further customization

# variable "node_group_desired_size" {
#   type = number
#   default = 2
# }

# variable "ssh_key" {
#   type = string
#   default = "your_ssh_key"
# }