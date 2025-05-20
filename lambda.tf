resource "aws_lambda_function" "attach_ebs_lambda" {
  function_name = "attach-ebs-volume"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role = aws_iam_role.lambda_exec.arn
}
