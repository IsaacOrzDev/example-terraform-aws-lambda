output "lambda" {
  value = [
    for i, funciton in var.lambda_functions : aws_lambda_function.lambda[i].qualified_arn
  ]
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_api_gateway_deployment.api.invoke_url
}

output "custom_url" {
  value = aws_api_gateway_base_path_mapping.api.domain_name
}
