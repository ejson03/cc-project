resource "aws_lambda_function" "handler_function" {
    function_name = "handler_function"
    filename = var.lambda_payload_filename
    role = aws_iam_role.lambda_apigateway_iam_role.arn
    handler = var.lambda_function_handler
    source_code_hash = base64sha256(filebase64(var.lambda_payload_filename))
    runtime = var.lambda_runtime 
}

resource "aws_lambda_permission" "handler_permission"{
    statement_id = "AllowExceutionFromApiGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.handler_function.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.handler_api.execution_arn}/*/*"
}