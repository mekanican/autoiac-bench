provider "aws" {
  region = "us-west-2"
}

output "access_key" {
  value = aws_iam_access_key.example.access_key
}