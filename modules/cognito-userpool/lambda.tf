resource "aws_lambda_function" "auto-confirm-lambda" {
  function_name    = "auto-confirm-signup"
  handler          = "pre-sign-lambda.handler"
  role             = aws_iam_role.invoke-and-cognito.arn
  runtime          = "nodejs12.x"
  filename         = "${path.module}/lambda-triggers/pre-sign-lambda.zip"
  source_code_hash = data.archive_file.lambda-pre-sign-archive.output_base64sha256

  tags = {
    category = "terraform"
  }
}

resource "aws_lambda_function" "assign-group-lambda" {
  function_name    = "assign-group"
  handler          = "post-confirm-lambda.addUserToGroup"
  role             = aws_iam_role.invoke-and-cognito.arn
  runtime          = "nodejs12.x"
  filename         = "${path.module}/lambda-triggers/post-confirm-lambda.zip"
  source_code_hash = data.archive_file.lambda-post-confirm-archive.output_base64sha256

  tags = {
    category = "terraform"
  }
}

data "archive_file" "lambda-pre-sign-archive" {
  type        = "zip"
  source_file = "${path.module}/lambda-triggers/pre-sign-lambda.js"
  output_path = "${path.module}/lambda-triggers/pre-sign-lambda.zip"
}

data "archive_file" "lambda-post-confirm-archive" {
  type        = "zip"
  source_file = "${path.module}/lambda-triggers/post-confirm-lambda.js"
  output_path = "${path.module}/lambda-triggers/post-confirm-lambda.zip"
}

resource "aws_lambda_permission" "trigger-pre" {
  statement_id  = "AllowCognitoTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto-confirm-lambda.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = aws_cognito_user_pool.cognito-module-user-pool.arn
}

resource "aws_lambda_permission" "trigger-post" {
  statement_id  = "AllowCognitoTrigger_2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.assign-group-lambda.function_name
  principal     = "cognito-idp.amazonaws.com"

  source_arn = aws_cognito_user_pool.cognito-module-user-pool.arn
}



resource "aws_iam_role" "invoke-and-cognito" {
  name = "invoke-lambda-and-cognito-groups"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

data aws_iam_policy_document "assume-role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = ""
  }
}

resource "aws_iam_policy" "cognito-policy" {
  name = "my-test-policy"
  description = "A test policy"


  policy = data.aws_iam_policy_document.cognito-policy-document.json
}

data "aws_iam_policy_document" "cognito-policy-document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["cognito-idp:AdminAddUserToGroup", "logs:*", "cognito-idp:AdminRemoveUserFromGroup", "cognito-idp:AdminAddUserToGroup"]
    resources = [aws_cognito_user_pool.cognito-module-user-pool.arn]
  }
}


resource "aws_iam_role_policy_attachment" "lambda-to-cognito-attachment" {
  role       = aws_iam_role.invoke-and-cognito.name
  policy_arn = aws_iam_policy.cognito-policy.arn
}