terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws",
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}
//Create keypair for my instance
resource "tls_private_key" "us_mgt"{
    algorithm = "RSA"
    rsa_bits = "4096"
}
resource "aws_key_pair" "us_mgt"{
    key_name = "us_mgt"
    public_key = tls_private_key.us_mgt.public_key_openssh
}
//save the private key
resource "local_file" "us_mgt"{
    content = tls_private_key.us_mgt.private_key_pem
    filename = "us_mgt.pem"
}
resource "aws_security_group" "us_mgt_sg" {
  name        = "us_mgt_sg"
  description = "This allows access to the instances"
  vpc_id      = "vpc-0b9139154961fc3e3"

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic for us_mgt_instance"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Security group for us_mgt_sg"
  }
}
//Create an instance
resource "aws_instance" "us_mgt"{
    ami = "ami-04b70fa74e45c3917"
    instance_type = "t2.micro"
    count = 1
    subnet_id = "subnet-0fe9e2a0a263498d4"
    key_name = aws_key_pair.us_mgt.key_name
    vpc_security_group_ids = [aws_security_group.us_mgt_sg.id]
    associate_public_ip_address = true
    user_data = file("/home/kikelomo/bash-terraform-class1/installation.sh")
    tags = {
        Name = "us_mgt"
    }
}
