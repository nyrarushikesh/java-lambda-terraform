output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "function_url" {
  value       = aws_lambda_function_url.this.function_url
  description = "The HTTP URL endpoint for the Lambda function"
}
