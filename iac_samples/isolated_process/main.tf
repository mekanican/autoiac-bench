resource "aws_instance" "component1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "Component 1"
  }
}

resource "aws_s3_bucket" "component2" {
  bucket = "component2-bucket"
  acl    = "private"
}

resource "aws_iam_user" "component3" {
  name = "component3_user"
}

resource "aws_db_instance" "component4" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "component4db"
  username             = "admin"
  password             = "Password123"
}

resource "aws_lambda_function" "component5" {
  filename         = "lambda_function_payload.zip"
  function_name    = "component5_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "exports.handler"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime          = "nodejs12.x"
}