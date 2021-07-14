resource "aws_lambda_function" "terraform_gateway_lambda_hello_world" {
  function_name    = "hello-lambda-world"
  handler          = "main.handler"
  role             = aws_iam_role.terraform_lambda_exec_role.arn
  runtime          = "nodejs12.x"
  filename         = "${path.module}/lambdas/main.zip"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  tags = {
    category = "terraform"
  }
}

resource "aws_iam_role" "terraform_lambda_exec_role" {
  # this style of declaration can be replaced/supplemented with a data block for an iam policy statement. it looks much cleaner and has syntax highlighting.
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_gateway_lambda_hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.terraform_gateway_test.execution_arn}/*/*"
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambdas/main.js"
  output_path = "${path.module}/lambdas/main.zip"
}