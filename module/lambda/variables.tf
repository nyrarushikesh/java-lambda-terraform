variable "region" {
  description = "AWS region"
  type        = string
}

variable "envname" {
  description = "Environment name"
  type        = string
}

variable "bucket" {
  description = "Terraform backend bucket"
  type        = string
}
