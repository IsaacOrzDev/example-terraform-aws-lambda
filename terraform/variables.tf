variable "aws_region" {
  default = "us-west-1"
}

variable "domain_name" {
  type = string
}

variable "sub_domain_name" {
  type = string
}

variable "bucket_name" {
  type    = string
  default = "welcome"

  validation {
    condition     = length(var.bucket_name) > 1 && length(var.bucket_name) <= 140
    error_message = "expected length of bucket_name to be in the range (1 - 140)"
  }
}

variable "lambda_functions" {
  type = list(
    object({
      filename      = string
      source_file   = string
      route_key     = string
      handler       = string
      runtime       = string
      function_name = string
    })
  )
  default = [
    {
      filename      = "welcome"
      source_file   = "../src/welcome.py"
      handler       = "lambda_handler"
      route_key     = "GET /"
      runtime       = "python3.10"
      function_name = "welcome1"
    },
    {
      filename      = "welcome"
      source_file   = "../src/welcome.py"
      handler       = "lambda_handler2"
      route_key     = "GET /welcome"
      runtime       = "python3.10"
      function_name = "welcome2"
    }
  ]
}
