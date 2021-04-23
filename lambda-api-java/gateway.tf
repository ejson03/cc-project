resource "aws_api_gateway_rest_api" "handler_api" {
  name = "HandlerApi"
  description = "Terraform serverless handler"
}

resource "aws_api_gateway_resource" "proxy_resource" {
   rest_api_id = aws_api_gateway_rest_api.handler_api.id
   parent_id   = aws_api_gateway_rest_api.handler_api.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
   rest_api_id   = aws_api_gateway_rest_api.handler_api.id
   resource_id   = aws_api_gateway_resource.proxy_resource.id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.handler_api.id
   resource_id = aws_api_gateway_method.proxy_method.resource_id
   http_method = aws_api_gateway_method.proxy_method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.handler_function.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.handler_api.id
   resource_id   = aws_api_gateway_rest_api.handler_api.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.handler_api.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.handler_function.invoke_arn
}

resource "aws_api_gateway_deployment" "handler" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]
   rest_api_id = aws_api_gateway_rest_api.handler_api.id
   stage_name  = "test"
}

output "base_url" {
  value = aws_api_gateway_deployment.handler.invoke_url
}