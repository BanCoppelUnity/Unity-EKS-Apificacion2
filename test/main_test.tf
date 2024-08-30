# Define una variable local que se usará como sufijo en los nombres de los recursos
locals {
  tags = merge(var.tags, {
    "Date/Time"   = timeadd(timestamp(), "-6h")
    "Environment" = var.environment
    }
  )
}

# Se especifica la versión de Terraform necesario para ejecutar el código
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Se configura el proveedor AWS, especificando la región.
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

# Se especifica el bucket s3 donde está almacenado el terraform state de Networking
data "terraform_remote_state" "ntw_out" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket               = var.bucket
    key                  = var.key
    workspace_key_prefix = var.workspace_key_prefix
    region               = var.bucket_region
    endpoints = {
      s3 = "https://s3.us-east-1.amazonaws.com"
    }
  }
}

# Obtiene las credenciales del usuarios AWS que está ejecutando el despliegue
data "aws_caller_identity" "current" {}

# Se ejecuta el módulo de EKS para crear el clúster de EKS, los nodos gestionados de Kubernetes y el AWS Load Balancer Controller
module "eks" {
  source               = "git::https://github.com/BanCoppelUnity/Unity-eks-module.git?ref=v1.0.0-rc.1"
  security_groups_id   = [for security_group_name, security_group_id in data.terraform_remote_state.ntw_out.outputs.security_groups_id : security_group_id if can(regex("eks", security_group_name))]
  vpc_id               = data.terraform_remote_state.ntw_out.outputs.vpc_id
  subnets_id           = [for subnet_name, subnet_id in data.terraform_remote_state.ntw_out.outputs.subnets_id : subnet_id if can(regex("eks", subnet_name))]
  prefix               = var.prefix
  description          = var.description
  aws_region           = var.aws_region
  environment          = var.environment
  eks_version          = var.eks_version
  ami_owner            = var.ami_owner
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
  instance_type        = var.instance_type
  volume_size          = var.volume_size
  volume_type          = var.volume_type
  tags                 = local.tags
  roles_auth = [
    {
      rolearn  = module.eks.node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      groups   = ["system:masters"]
      rolearn  = module.eks.eks_admin_role_arn,
      username = "eks-admin"
    },
    {
      groups   = [""]
      rolearn  = module.eks.eks_developer_role_arn,
      username = "eks-developer"
    }
  ]
}