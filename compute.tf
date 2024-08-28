# Instancia EC2
resource "aws_instance" "wordpress" {
  ami = "ami-085f9c64a9b75eed5"
  instance_type = "t3a.small"
  key_name = "KP-proyecto-wordpress"
  subnet_id = aws_subnet.public-subnet-proyecto.id
  security_groups = [aws_security_group.sg_wordpress-proyecto.id]
  associate_public_ip_address = false 
  tags = {
    Name = "wordpress"
  }
}

# Asociación de la ip elástica
resource "aws_eip_association" "aep-assoc" {
  instance_id = aws_instance.wordpress.id
  allocation_id = aws_eip.eip-proyecto.id 
}

# Instancia RDS
resource "aws_db_instance" "rds-instance" {
  engine = "mysql"
  engine_version = "8.0.32"
  skip_final_snapshot = true
  final_snapshot_identifier = "snapshot-rds"
  instance_class = "db.t3.small"
  allocated_storage = 20
  identifier = "rds-proyecto"
  db_name = "db_wordpress"
  username = "admin"
  password = "admin1234"
  db_subnet_group_name = aws_db_subnet_group.rds-subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_securit_group.id]
  tags = {
    Name = "rds-instance"
  }
}

# Security Group for RDS Instance
resource "aws_security_group" "rds_securit_group" {
  name = "rds_securit_group"
  description = "Security group for RDS instance"
  vpc_id = aws_vpc.vpc-proyecto.id
  # reglas de entrada
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    #cidr_blocks = [ "10.20.0.0/16" ]
    security_groups = [ aws_security_group.sg_wordpress-proyecto.id ]
  }
  tags = {
    Name = "rds-security-group"
  }
}
