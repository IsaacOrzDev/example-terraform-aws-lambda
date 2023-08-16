output "lambda" {
  value = aws_lambda_function.lambda.qualified_arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.lambda.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}
