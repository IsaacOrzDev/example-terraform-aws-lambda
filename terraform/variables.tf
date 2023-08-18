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
  type = string
  default = "GET /"
}
