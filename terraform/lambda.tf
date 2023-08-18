
resource "aws_lambda_function" "lambda" {

  for_each = { for i, funciton in var.lambda_functions : i => funciton }

  function_name = each.value.function_name
  # filename         = data.archive_file.zip.output_path
  # source_code_hash = data.archive_file.zip.output_base64sha256
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_s3_object[each.key].key
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "${each.value.filename}.${each.value.handler}"
  runtime          = each.value.runtime
  source_code_hash = data.archive_file.zip[each.key].output_base64sha256
}
