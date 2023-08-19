data "archive_file" "zip" {
  for_each = { for i, funciton in var.lambda_functions : i => funciton }

  type        = "zip"
  source_file = each.value.source_file
  output_path = "../${each.value.filename}.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = var.bucket_name
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_object" "lambda_s3_object" {

  for_each = local.lambda_functions

  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${each.value.filename}.zip"
  source = data.archive_file.zip[each.key].output_path

  etag = filemd5(data.archive_file.zip[each.key].output_path)
}
