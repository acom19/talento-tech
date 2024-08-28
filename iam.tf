# Crear un rol de IAM
resource "aws_iam_role" "read_only_role" {
  name = "db-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Crear la política de solo lectura para la instancia RDS
resource "aws_iam_policy" "rds_read_only_policy" {
  name        = "RDSReadOnlyPolicy"
  description = "Policy for read-only access to RDS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["rds:Describe*", "rds:List*"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = ["rds-db:connect"],
        Effect   = "Allow",
        Resource = "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.rds-instance.resource_id}/readonlyuser"
      }
    ]
  })
}

# Adjuntar la política al rol
resource "aws_iam_role_policy_attachment" "attach_read_only_policy" {
  role       = aws_iam_role.read_only_role.name
  policy_arn = aws_iam_policy.rds_read_only_policy.arn
}

# Crear una instancia EC2 con el rol asociado
resource "aws_instance" "wordpress" {
  ami                         = "ami-085f9c64a9b75eed5"
  instance_type               = "t3a.small"
  key_name                    = "KP-proyecto-wordpress"
  subnet_id                   = aws_subnet.public-subnet-proyecto.id
  security_groups             = [aws_security_group.sg_wordpress-proyecto.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.read_only_instance_profile.name

  tags = {
    Name = "wordpress"
  }
}

# Crear un perfil de instancia de IAM para asignar el rol a la EC2
resource "aws_iam_instance_profile" "read_only_instance_profile" {
  name = "db-readonly-instance-profile"
  role = aws_iam_role.read_only_role.name
}