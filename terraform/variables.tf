variable "aws_region" {
  default = "us-west-1"
}

variable "domain_name" {
  type = string
}

variable "sub_domain_name" {
  type = string
}

variable "route_key" {
  type    = string
  default = "GET /"
}

variable "source_file" {
  type    = string
  default = "../src/welcome.py"
}

variable "filename" {
  type    = string
  default = "welcome"

  validation {
    condition     = length(var.filename) > 1 && length(var.filename) <= 140
    error_message = "expected length of filename to be in the range (1 - 140)"
  }
}
