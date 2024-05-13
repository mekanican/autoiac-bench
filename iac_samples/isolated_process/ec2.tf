variable "ami" {
  default = "ami-0c55b159cbfafe1f0"  # Example AMI, change as needed
}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "EC2 Instance"
  }
}