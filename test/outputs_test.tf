output "cluster_arn" {
  description = "El ARN del clúster de EKS"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "El endpoint del clúster de EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "El nombre del clúster de EKS"
  value       = module.eks.cluster_name
}

output "cluster_ca_certificate" {
  description = "El certificado CA del clúster de EKS"
  value       = module.eks.cluster_ca_certificate
}

output "node_names" {
  description = "Los nombres de los grupos de nodos gestionados de Kubernetes"
  value       = module.eks.node_names
}

output "node_role_arn" {
  description = "El ARN del rol de los nodos gestionados de Kubernetes"
  value       = module.eks.node_role_arn
}

output "eks_admin_role_arn" {
  description = "El ARN del rol de administrador de EKS"
  value       = module.eks.eks_admin_role_arn
}

output "eks_developer_role_arn" {
  description = "El ARN del rol de desarrollador de EKS"
  value       = module.eks.eks_developer_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "El ARN del rol del AWS Load Balancer Controller"
  value       = module.eks.aws_load_balancer_controller_role_arn
}