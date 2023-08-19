resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "${var.sub_domain_name}.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  depends_on = [aws_acm_certificate_validation.api]
}

resource "aws_route53_record" "api" {
  name    = aws_apigatewayv2_domain_name.api.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# resource "aws_apigatewayv2_api_mapping" "api" {
#   # api_id      = aws_apigatewayv2_api.lambda.id
#   api_id      = aws_api_gateway_rest_api.api.id
#   domain_name = aws_apigatewayv2_domain_name.api.id
#   # stage       = aws_apigatewayv2_stage.lambda.id
#   stage = aws_api_gateway_deployment.api.id
# }

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api.stage_name
  domain_name = aws_apigatewayv2_domain_name.api.id
}
