variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "profile" {
  description = "Nombre de perfil para el despliegue de la infraestructura"
  type        = string
}

variable "bucket" {
  description = "Nombre del Bucket de S3 donde está el terraform state de Networking"
  type        = string
}

variable "bucket_region" {
  description = "Región de AWS del Bucket de S3 donde está el terraform state de Networking"
  type        = string
}

variable "key" {
  description = "Llave del bucket S3 donde está el terraform state de Networking"
  type        = string
}

variable "workspace_key_prefix" {
  description = "Prefijo del espacio de trabajo para la Llave del bucket S3 donde está el terraform state de Networking"
  type        = string
}

variable "prefix" {
  description = "Prefijo para nombrar los recursos creados"
  type        = string
}

variable "description" {
  description = "Descripción del recurso relacionado a la iniciativa"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "eks_version" {
  description = "La versión de EKS a utilizar para el clúster y los worker nodes"
  type        = string
}

variable "ami_owner" {
  description = "ID de la cuenta de AWS propietaria de la AMI"
  type        = set(string)
}

variable "asg_desired_capacity" {
  description = "El número de instancias de Amazon EC2 que deberían estar funcionando en el grupo de autoescalamiento."
  type        = number
}

variable "asg_max_size" {
  description = "El número máximo de instancias de Amazon EC2 en el grupo de autoescalamiento."
  type        = number
}

variable "asg_min_size" {
  description = "El número mínimo de instancias de Amazon EC2 en el grupo de autoescalamiento."
  type        = number
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el grupo de autoescalamiento."
  type        = string
}

variable "volume_size" {
  description = "Tamaño del SSD de la instancia EC2"
  type        = number
}

variable "volume_type" {
  description = "Tipo del SSD de la instancia EC2"
  type        = string
}

variable "usuarios_auth" {
  description = "Lista de usuarios autorizados en el configmap de EKS para conexión"
  type        = list(any)
  default     = []
}

variable "cuentas_aws_auth" {
  description = "Lista de cuentas autorizados en el configmap de EKS para conexión"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Etiquetas base para los recursos"
  type        = map(string)
}