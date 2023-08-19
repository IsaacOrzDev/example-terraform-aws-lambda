variable "aws_region" {
  default = "us-west-1"
}

variable "domain_name" {
  type = string
}

variable "sub_domain_name" {
  type = string
}

variable "stage_name" {
  type = string
  default = "test"
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
      route_key     = optional(string)
      path_part     = optional(string)
      http_method   = string
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
      runtime       = "python3.10"
      function_name = "welcome1"
      http_method   = "GET"
    },
    {
      filename      = "welcome"
      source_file   = "../src/welcome.py"
      handler       = "lambda_handler2"
      runtime       = "python3.10"
      function_name = "welcome2"
      http_method   = "POST"
    },
    {
      filename      = "testing"
      source_file   = "../src/testing.py"
      handler       = "lambda_handler"
      runtime       = "python3.10"
      function_name = "welcome3"
      path_part     = "testing"
      http_method   = "GET"
    },
    {
      filename      = "welcome2"
      source_file   = "../src/welcome2.js"
      handler       = "handler"
      runtime       = "nodejs18.x"
      function_name = "welcome4"
      path_part     = "welcome"
      http_method   = "POST"
    },
  ]
}

locals {
  lambda_functions           = { for i, funciton in var.lambda_functions : i => funciton }
  lambda_function_path_parts = toset(distinct(compact([for i, funciton in var.lambda_functions : funciton.path_part])))
}
