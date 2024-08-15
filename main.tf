terraform { required_providers {
  aws = { source = "hashicorp/aws" }
}

provider "aws" {
  region = var.aws_region
}

locals {
  eks_cluster_name = var.cluster_name
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  node_group_instance_type = var.node_group_instance_type
  node_group_min_size = var.node_group_min_size
  node_group_max_size = var.node_group_max_size
}

# VPC and Subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = local.eks_cluster_name
  cidr_block = local.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  azs = data.aws_availability_zones.available.names
  public_subnets = { for i in range(length(local.public_subnet_cidr_blocks)) : i => { cidr_block = local.public_subnet_cidr_blocks[i] } }
  private_subnets = { for i in range(length(local.private_subnet_cidr_blocks)) : i => { cidr_block = local.private_subnet_cidr_blocks[i] } }
  # Additional VPC configuration as needed
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = module.vpc.public_subnets[0].id
}

# EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name = local.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = data.aws_eks_cluster_versions.latest.latest
  # Optional: Enable private access for cluster
  # endpoint_private_access = true
  # Optional: Enable encryption at rest for EKS data
  # encryption_config {
  #   provider = "aws"
  # }
  # Optional: Configure VPC peering
  #  vpc_config {
  #    subnet_ids = [ module.vpc.private_subnets[*].id ]
  #    security_group_ids = [ aws_security_group.eks_cluster_sg.id ]
  #  }
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "${local.eks_cluster_name}-node-group"
  node_role_arn = aws_iam_role.eks_node_role.arn
  # Optional: Use managed node group
  #  instance_types = [local.node_group_instance_type]
  #  disk_size = 100
  #  scaling_config {
  #    desired_size = 2
  #    min_size = 1
  #    max_size = 4
  #  }
  #  update_config {
  #    max_unavailable = 1
  #  }
  #  launch_template {
  #    id = aws_launch_template.node_group_launch_template.id
  #  }
  #  subnets = [module.vpc.private_subnets[*].id]
  #  # Optional: Enable encryption at rest
  #  remote_access {
  #    source_security_group_ids = [aws_security_group.eks_cluster_sg.id]
  #    ec2_ssh_key = var.ssh_key
  #  }
  # Optional: Enable autoscaling
  #  scaling_config {
  #    desired_size = var.node_group_desired_size
  #    min_size = var.node_group_min_size
  #    max_size = var.node_group_max_size
  #  }
}

# Security Groups
resource "aws_security_group" "eks_cluster_sg" {
  name = "${local.eks_cluster_name}-eks-cluster-sg"
  description = "Security Group for EKS Cluster"
  vpc_id = module.vpc.id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_cluster_sg_allow_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

# IAM Roles
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.eks_cluster_name}-eks-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks_node_role" {
  name = "${local.eks_cluster_name}-eks-node-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Policies
resource "aws_iam_policy" "eks_cluster_policy" {
  name = "${local.eks_cluster_name}-eks-cluster-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListRoles",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:DeleteRepository",
        "ecr:DescribeRegistry"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey",
        "kms:Encrypt"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name = "${local.eks_cluster_name}-eks-cluster-policy-attachment"
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}

resource "aws_iam_policy_attachment" "eks_node_policy_attachment" {
  name = "${local.eks_cluster_name}-eks-node-policy-attachment"
  role = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.eks_cluster_policy.arn
}

# Outputs
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority.data
}

output "node_group_id" {
  value = aws_eks_node_group.node_group.id
}

output "vpc_id" {
  value = module.vpc.id
}

output "private_subnets" {
  value = module.vpc.private_subnets[*].id
}

output "public_subnets" {
  value = module.vpc.public_subnets[*].id
}