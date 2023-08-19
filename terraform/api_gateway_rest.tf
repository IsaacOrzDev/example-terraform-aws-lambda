resource "aws_api_gateway_rest_api" "api" {
  name = "serverless example"
}


resource "aws_api_gateway_resource" "proxy" {
  for_each = local.lambda_function_path_parts

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value
}


resource "aws_api_gateway_method" "proxy" {
  for_each = local.lambda_functions

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.path_part == null ? aws_api_gateway_rest_api.api.root_resource_id : aws_api_gateway_resource.proxy["${each.value.path_part}"].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  for_each = local.lambda_functions

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = each.value.path_part == null ? aws_api_gateway_rest_api.api.root_resource_id : aws_api_gateway_resource.proxy["${each.value.path_part}"].id
  http_method = aws_api_gateway_method.proxy[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda[each.key].invoke_arn
}


resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

resource "aws_lambda_permission" "apigw" {
  for_each = local.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
