resource "aws_s3_bucket" "s3_bucket" {
  bucket = "example-bucket"
  acl    = "private"
}