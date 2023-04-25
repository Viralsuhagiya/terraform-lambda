locals {
    lambda_zip_location = "outputs/welcome.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "archive_file" "welcome" {
  type        = "zip"
  source_file = "welcome.py"
  output_path = "${local.lambda_zip_location}"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${local.lambda_zip_location}"
  function_name = "welcome"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "welcome.hello"
  source_code_hash = data.archive_file.welcome.output_base64sha256
  runtime = "python3.7"
}
