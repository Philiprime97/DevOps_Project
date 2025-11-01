provider "aws" {
  region = var.region
}

# ---------------------
# VPC + Subnet
# ---------------------
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true  # assign public IP automatically
  tags = { Name = "main-subnet" }
}

# ---------------------
# Internet Gateway
# ---------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "main-igw" }
}

# ---------------------
# Route Table
# ---------------------
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "main-rt" }
}

resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

# ---------------------
# Security Groups
# ---------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH, k3s, app ports, monitoring"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort range for app services, Grafana, Prometheus
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------
# Jenkins EC2
# ---------------------
resource "aws_instance" "jenkins" {
  ami           = "ami-043339ea831b48099" # Amazon Linux 2
  instance_type = var.jenkins_instance_type
  key_name = var.jenkins_key_name
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  tags = { Name = "Jenkins-Server" }
}

# ---------------------
# App + k3s EC2
# ---------------------
resource "aws_instance" "app" {
  ami           = "ami-043339ea831b48099" # Amazon Linux 2
  instance_type = var.app_instance_type
  key_name = var.app_key_name
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  tags = { Name = "App-k3s-Server" }
}

# ---------------------
# Thanos S3 Bucket
# ---------------------
resource "aws_s3_bucket" "thanos_bucket" {
  bucket = var.thanos_s3_bucket
}


# ---------------------
# IAM Role for EC2 to access S3 (for Thanos)
# ---------------------
resource "aws_iam_role" "ec2_thanos_role" {
  name = "ec2-thanos-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "thanos_s3_attach" {
  role       = aws_iam_role.ec2_thanos_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
