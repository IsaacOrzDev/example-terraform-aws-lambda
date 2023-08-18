resource "aws_lambda_function" "lambda" {
  function_name = var.filename
  # filename         = data.archive_file.zip.output_path
  # source_code_hash = data.archive_file.zip.output_base64sha256
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_s3_object.key
  role      = aws_iam_role.iam_for_lambda.arn
  handler   = "${var.filename}.lambda_handler"
  runtime   = "python3.10"
}
