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

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "jar_path" {
  description = "Path to the Lambda JAR file"
  type        = string
}
