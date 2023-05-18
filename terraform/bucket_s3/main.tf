provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "exemplo-bucket" {
  bucket = "ifpb"
  acl    = "private"

  tags = {
    Name = "Exemplo de bucket S3"
  }
}
