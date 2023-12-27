# Définition du VPC
resource "aws_vpc" "vpc-test-1" {
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "srv-test-1"
  }
}

# Définition du groupe de sécurité
resource "aws_security_group" "sg-test-1" {
  vpc_id = aws_vpc.vpc-test-1.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Définition des sous-réseaux
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

# Génération de la paire de clés SSH
resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key_file" {
  content  = tls_private_key.example_key.private_key_pem
  filename = "private_key.pem"
}

output "private_key_pem" {
  value = tls_private_key.example_key.private_key_pem
  sensitive = true
}

# Création de la paire de clés AWS Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "srv-test-1-key"
  public_key = tls_private_key.example_key.public_key_openssh
}

# Création de la passerelle Internet
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
    gateway_id  = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table-srv-test-1"
  }
}

# Association des sous-réseaux à la table de routage publique
resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.subnet-test-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.subnet-test-2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Création de l'instance EC2
resource "aws_instance" "srv-test-1" {
  ami           = "ami-01d21b7be69801c2f"
  instance_type = "t2.micro"
  tags = {
    Name = "srv-test-1"
  }

  key_name      = aws_key_pair.key_pair.key_name

  associate_public_ip_address = true

  subnet_id = aws_subnet.subnet-test-1.id

  vpc_security_group_ids = [aws_security_group.sg-test-1.id]
}
