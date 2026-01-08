output "lambda_arn" {
  value = module.lambda.lambda_arn
}

output "function_url" {
  value       = module.lambda.function_url
  description = "Lambda Function URL"
}
