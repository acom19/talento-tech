# Se agrega comentario en línea 1
# AWS Provider
provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}
