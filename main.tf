provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "from_rabbit" {
  filename         = "lambda.zip"
  function_name    = "hello_from_rabbit"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_mq_broker" "rabbit" {
  broker_name       = "rabbitmq-broker"
  engine_type       = "RabbitMQ"
  engine_version    = "3.8.35"
  host_instance_type = "mq.t3.micro"
  publicly_accessible = true

  user {
    username = var.rabbit_user
    password = var.rabbit_pass
  }

  logs {
    general = true
  }
}

resource "aws_lambda_event_source_mapping" "rabbit_event" {
  event_source_arn = aws_mq_broker.rabbit.arn
  function_name    = aws_lambda_function.from_rabbit.arn
  enabled          = true
}
