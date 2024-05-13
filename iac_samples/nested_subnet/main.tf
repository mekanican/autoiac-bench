# Define provider
provider "aws" {
  region = "us-east-1" # Specify your desired AWS region
}

# Create VPCs
resource "aws_vpc" "ec2_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "dynamodb_elasticcache_vpc" {
  cidr_block = "10.1.0.0/16"
}

# Create security groups
resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Security group for ELB"
  vpc_id      = aws_vpc.ec2_vpc.id

  // Define your ELB specific ingress rules here
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.ec2_vpc.id

  // Define your EC2 specific ingress rules here
}

# Create ELB
resource "aws_elb" "example" {
  name               = "example-elb"
  availability_zones = ["us-east-1a", "us-east-1b"] # Specify desired AZs
  security_groups    = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  // Add other ELB configurations as needed
}

# Create EC2 instances
resource "aws_instance" "ec2_instances" {
  count         = 2
  ami           = "ami-12345678" # Specify your desired AMI
  instance_type = "t2.micro" # Specify your desired instance type
  subnet_id     = aws_subnet.ec2_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]

  // Add other EC2 configurations as needed
}

# Create DynamoDB table
resource "aws_dynamodb_table" "example" {
  name           = "example-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }

  // Add other DynamoDB configurations as needed
}

# Create ElasticCache cluster
resource "aws_elasticache_cluster" "example" {
  cluster_id           = "example-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"

  // Add other ElasticCache configurations as needed
}

# Create connections
# Connection from ELB to EC2
resource "aws_instance_elb_attachment" "elb_attachment" {
  instances  = aws_instance.ec2_instances[*].id
  elb        = aws_elb.example.name
}

# Connection from EC2 to DynamoDB
# Assume you have IAM role allowing EC2 instances to access DynamoDB
# You should define the IAM role separately and reference it here
resource "aws_iam_instance_profile" "example" {
  name = "example-profile"
  role = aws_iam_role.example.name
}

resource "aws_iam_role" "example" {
  name = "example-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" # Adjust with your desired policy
}

# Connection from EC2 to ElasticCache
# You need to configure access to ElasticCache in the EC2 security group
# Ensure necessary ports and permissions are allowed

# Create Subnets
resource "aws_subnet" "ec2_subnet" {
  vpc_id            = aws_vpc.ec2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Specify your desired AZ
}

resource "aws_subnet" "dynamodb_elasticcache_subnet" {
  vpc_id            = aws_vpc.dynamodb_elasticcache_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1b" # Specify your desired AZ
}
