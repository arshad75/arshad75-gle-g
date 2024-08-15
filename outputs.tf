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