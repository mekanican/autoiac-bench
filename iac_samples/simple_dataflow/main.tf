resource "aws_instance" "component_a" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "Component A"
  }
}

resource "aws_instance" "component_b" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "Component B"
  }
}

# Component C - AWS EC2 Instance
resource "aws_instance" "component_c" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "Component C"
  }
}

resource "aws_s3_bucket" "data_flow_A_to_B" {
  bucket = "data-flow-A-to-B-bucket"
  acl    = "private"
}

resource "aws_s3_bucket" "data_flow_B_to_C" {
  bucket = "data-flow-B-to-C-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policy_A_to_B" {
  bucket = aws_s3_bucket.data_flow_A_to_B.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.data_flow_A_to_B.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_policy" "policy_B_to_C" {
  bucket = aws_s3_bucket.data_flow_B_to_C.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.data_flow_B_to_C.arn}/*"
    }]
  })
}