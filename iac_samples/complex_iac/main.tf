# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet for Component A
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create private subnet for Component B
resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Create private subnet for Component C within subnet B
resource "aws_subnet" "subnet_c" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.3.0/24"
  depends_on = [aws_subnet.subnet_b]
}

# Component A - EC2 Instance in public subnet
resource "aws_instance" "component_a" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_a.id
  tags = {
    Name = "Component A"
  }
}

# Component B - EC2 Instance in private subnet
resource "aws_instance" "component_b" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_b.id
  tags = {
    Name = "Component B"
  }
}

# Component C - EC2 Instance in a different private subnet within subnet B
resource "aws_instance" "component_c" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_c.id
  tags = {
    Name = "Component C"
  }
}

# Data flow from A to B
resource "aws_s3_bucket" "data_flow_A_to_B" {
  bucket = "data-flow-A-to-B-bucket"
  acl    = "private"
}

# Data flow from B to C
resource "aws_s3_bucket" "data_flow_B_to_C" {
  bucket = "data-flow-B-to-C-bucket"
  acl    = "private"
}

# Grant permissions for Component B to access the bucket from Component A
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

# Grant permissions for Component C to access the bucket from Component B
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

resource "external" "third_party_a" {
  # Configuration for third party resource A
}

# Third party resources interacting with Component B
resource "external" "third_party_b" {
  # Configuration for third party resource B
}