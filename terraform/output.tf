output "lambda" {
  value = [
    for i, funciton in var.lambda_functions : aws_lambda_function.lambda[i].qualified_arn
  ]
}

output "function_name" {
  description = "Name of the Lambda function."
  value = [
    for i, funciton in var.lambda_functions : aws_lambda_function.lambda[i].function_name
  ]
}


output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}
