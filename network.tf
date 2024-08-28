#Creación de vpc y subredes
#VPC
resource "aws_vpc" "vpc-proyecto" {
    cidr_block = "10.20.0.0/16"
    tags = {
      Name = "vpc-proyecto"
    }
}

#public subnet
resource "aws_subnet" "public-subnet-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  cidr_block = "10.20.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "public-subnet-proyecto"
  }
}

#Private subnet 1
resource "aws_subnet" "private-subnet1-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  cidr_block = "10.20.5.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "private-subnet1-proyecto"
  }
}

#Private subnet 2
resource "aws_subnet" "private-subnet2-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  cidr_block = "10.20.6.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "private-subnet2-proyecto"
  }
}

# Grupo de subredes
resource "aws_db_subnet_group" "rds-subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [aws_subnet.private-subnet1-proyecto.id, aws_subnet.private-subnet2-proyecto.id]
}

# Internet gateway
resource "aws_internet_gateway" "igw-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  tags = {
    Name = "igw-proyecto"
  }
}

# Elastic IP
resource "aws_eip" "eip-proyecto" {
  domain = "vpc"
}

# Public route table
resource "aws_route_table" "TR-public-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-proyecto.id
  }
  tags = {
    Name = "TR-public-proyecto"
  }
}

# Private route table
resource "aws_route_table" "TR-private-proyecto" {
  vpc_id = aws_vpc.vpc-proyecto.id
  tags = {
    Name = "TR-private-proyecto"
  }
}

# Asociar tabla de rutas publica
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public-subnet-proyecto.id
  route_table_id = aws_route_table.TR-public-proyecto.id
}

# Asociar tabla de rutas privadas
# La ruta local dentro de la VPC se crea automáticamente y no necesitas definirla explícitamente.
resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.private-subnet1-proyecto.id
  route_table_id = aws_route_table.TR-private-proyecto.id
}
resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.private-subnet2-proyecto.id
    route_table_id = aws_route_table.TR-private-proyecto.id
}

# Security group
resource "aws_security_group" "sg_wordpress-proyecto" {
  name = "sg_wordpress-proyecto"
  description = "Allow SSH inbound traffic"
  vpc_id = aws_vpc.vpc-proyecto.id
  # Indbound rules
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_wordpress-proyecto"
  }
}







