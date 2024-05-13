# Define provider
provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })

  # Attach policies as needed
  # e.g., 
  #   policy_arns = ["arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"]
}

# Create VPC for Lambda and RDS
resource "aws_vpc" "lambda_rds_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name    = "your_lambda_function"
  handler          = "lambda_function.handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_role.arn

  # Code for your lambda function
  # e.g., 
  #   filename = "lambda_function.zip"
  #   source_code_hash = filebase64sha256("lambda_function.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet.id] # Assuming you define the subnet
    security_group_ids = [aws_security_group.lambda_sg.id] # Assuming you define the security group
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "your_api_gateway"
  description = "API Gateway for your application"
}

# Create RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier            = "your_rds_instance"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t2.micro"
  name                  = "your_database_name"
  username              = "your_database_username"
  password              = "your_database_password"
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Assuming you define the security group
  subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
}

# Define subnet for Lambda
resource "aws_subnet" "lambda_subnet" {
  vpc_id                  = aws_vpc.lambda_rds_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Specify the AZ
}

# Define security group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.lambda_rds_vpc.id

  # Define ingress and egress rules as needed
  # e.g., 
  #   ingress {
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }
}

# Define security group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.lambda_rds_vpc.id

  # Define ingress and egress rules as needed
  # e.g., 
  #   ingress {
  #     from_port   = 3306
  #     to_port     = 3306
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }
}

# Define subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "your_rds_subnet_group"
  subnet_ids = [aws_subnet.lambda_subnet.id] # Assuming you define the subnet
}

# Connect API Gateway to Lambda
resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method             = "POST" # Or any method you prefer
  integration_http_method = "POST" # Or any method your lambda accepts
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# Connect Lambda to RDS (Assuming Lambda needs access to RDS)
# You may want to fine-tune access using security groups and IAM policies
resource "aws_lambda_function_permission" "lambda_rds_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}
