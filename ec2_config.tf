resource "aws_vpc" "vpc-test-1" {
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "srv-test-1"
  }
}

resource "aws_security_group" "sg-test-1" {
  vpc_id = aws_vpc.vpc-test-1.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }   

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "subnet-test-1" {
  vpc_id            = aws_vpc.vpc-test-1.id
  cidr_block        = "192.168.1.0/25"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "subnet1-test-1"
  }
}

resource "aws_subnet" "subnet-test-2" {
  vpc_id            = aws_vpc.vpc-test-1.id
  cidr_block        = "192.168.1.128/25"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "subnet1-test-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-test-1.id

  tags = {
    Name = "igw-srv-test-1"
  }
}

# Création de la table de routage publique
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc-test-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table-srv-test-1"
  }
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.subnet-test-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.subnet-test-2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_instance" "srv-test-1" {
  ami           = "ami-01d21b7be69801c2f"
  instance_type = "t2.micro"
  tags = {
    Name = "srv-test-1"
  }

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet-test-1.id
  vpc_security_group_ids      = [aws_security_group.sg-test-1.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF
}

