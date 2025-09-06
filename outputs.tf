output "lambda_url" {
  value = aws_lambda_function.from_rabbit.invoke_arn
}
