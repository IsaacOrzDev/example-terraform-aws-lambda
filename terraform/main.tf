provider "aws" {
  region = var.aws_region
}

provider "random" {

}

provider "archive" {}

#region s3 bucket for storing lamdba function

data "archive_file" "zip" {
  type        = "zip"
  source_file = "../src/welcome.py"
  output_path = "../welcome.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "welcome"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_object" "lambda_s3_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "welcome.zip"
  source = data.archive_file.zip.output_path

  etag = filemd5(data.archive_file.zip.output_path)
}

#endregion

# data "aws_iam_policy_document" "policy" {
#   statement {
#     sid    = ""
#     effect = "Allow"
#     principals {
#       identifiers = ["lambda.amazonaws.com"]
#       type        = "Service"
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

#region iam role for lambda functoin

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  # assume_role_policy = data.aws_iam_policy_document.policy.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#endregion

#region lambda

resource "aws_lambda_function" "lambda" {
  function_name = "welcome"
  # filename         = data.archive_file.zip.output_path
  # source_code_hash = data.archive_file.zip.output_base64sha256
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_s3_object.key
  role      = aws_iam_role.iam_for_lambda.arn
  handler   = "welcome.lambda_handler"
  runtime   = "python3.10"
}

#endregion

#region api gateway
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "welcome" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "welcome" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /welcome"
  target    = "integrations/${aws_apigatewayv2_integration.welcome.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}


#endregion
