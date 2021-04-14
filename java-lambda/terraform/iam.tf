resource "aws_iam_role" "lambda_apigateway_iam_role" {
  name = "lambda_apigateway_iam_role"
  assume_role_policy = file("./lambda_role.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_apigateway_iam_role.id
  policy = file("./lambda_policy.json")
}