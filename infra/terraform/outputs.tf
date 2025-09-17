output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnets" { value = module.vpc.public_subnets }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "eks_oidc_provider" { value = module.eks.oidc_provider }
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
output "ecr_backend_url" { value = aws_ecr_repository.backend.repository_url }
output "tools_public_ip" { value = aws_instance.tools.public_ip }
