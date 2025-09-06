provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "log_hola" {
  function_name = "log_hola"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda.zip"  # Lo tenés que generar con `zip -r lambda.zip .` desde carpeta lambda

  source_code_hash = filebase64sha256("lambda.zip")
}

# 🔄 EVENT SOURCE MAPPING (RabbitMQ)
resource "aws_lambda_event_source_mapping" "rabbit_to_lambda" {
  event_source_arn = "arn:aws:mq:us-east-1:YOUR_ACCOUNT_ID:broker:YOUR_BROKER_NAME:b-YOURID"  # ⚠️ reemplazá
  function_name     = aws_lambda_function.log_hola.arn
  enabled           = true
  batch_size        = 1
  source_access_configuration {
    type = "BASIC_AUTH"
    uri  = "arn:aws:secretsmanager:us-east-1:YOUR_ACCOUNT_ID:secret:your-secret" # usuario:pass en secreto
  }

  source_access_configuration {
    type = "VPC_SUBNET"
    uri  = "subnet-xxxxxxxxx"
  }

  source_access_configuration {
    type = "VPC_SECURITY_GROUP"
    uri  = "sg-xxxxxxxx"
  }
}
