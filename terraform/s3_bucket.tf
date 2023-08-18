data "archive_file" "zip" {
  type        = "zip"
  source_file = var.source_file
  output_path = "../${var.filename}.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = var.filename
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_object" "lambda_s3_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${var.filename}.zip"
  source = data.archive_file.zip.output_path

  etag = filemd5(data.archive_file.zip.output_path)
}
