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
