variable "aws_region" {
  description = "Región AWS donde serán desplegados los recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de ejecución"
  type        = string
  default     = "dev"
}
