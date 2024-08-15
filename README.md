# Terraform EKS Cluster Configuration

This Terraform configuration provides a production-ready deployment of an Amazon Elastic Kubernetes Service (EKS) cluster on AWS, incorporating best practices for security, scalability, and cost optimization.

## Prerequisites

- AWS Account
- Terraform installed and configured
- AWS CLI installed and configured

## Configuration Variables

The following variables are used in the Terraform configuration. You can modify these variables to customize the EKS cluster deployment:

| Variable Name | Description | Default Value | Optional |
|---|---|---|---|
| `aws_region` | AWS region for the EKS cluster | `us-east-1` | No | 
| `cluster_name` | Name of the EKS cluster | `my-eks-cluster` | No | 
| `vpc_cidr_block` | CIDR block for the VPC | `10.0.0.0/16` | No | 
| `public_subnet_cidr_blocks` | CIDR blocks for the public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` | No | 
| `private_subnet_cidr_blocks` | CIDR blocks for the private subnets | `["10.0.10.0/24", "10.0.20.0/24"]` | No | 
| `node_group_instance_type` | Instance type for the EKS node group | `t3.medium` | No | 
| `node_group_min_size` | Minimum number of instances in the node group | `2` | No | 
| `node_group_max_size` | Maximum number of instances in the node group | `4` | No | 

# Optional variables for further customization

# `node_group_desired_size` | Desired number of instances in the node group | `2` | Yes | 
# `ssh_key` | SSH key for access to the node group | `your_ssh_key` | Yes | 

## Usage

1. Create a new directory for your Terraform configuration.
2. Copy the Terraform configuration files (`main.tf`, `variables.tf`, etc.) to the directory.
3. Edit the `variables.tf` file and set the values for the required variables.
4. Initialize Terraform: `terraform init`
5. Plan the Terraform configuration: `terraform plan`
6. Apply the Terraform configuration: `terraform apply`

## Example Configuration for Development Environment

```terraform
# variables.tf
variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "my-eks-cluster-dev"
}

# ... rest of the variables
```

## Example Configuration for Staging Environment

```terraform
# variables.tf
variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "my-eks-cluster-staging"
}

# ... rest of the variables
```

## Example Configuration for Production Environment

```terraform
# variables.tf
variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "my-eks-cluster-prod"
}

# ... rest of the variables
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.