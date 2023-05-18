provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }

}

resource "aws_instance" "web" {
  #count                  = 3
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "Terraform-Web-Instance"
  }

  connection {
    host        = aws_instance.web.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa") # deve ser sem passphrase
    timeout     = "2m"
  }

  provisioner "local-exec" {
    command = "echo \"<html><body><h1>Olá, Terraform!</h1></body></html>\" > index.html"
  }

  provisioner "file" {
    source = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo service httpd start"
     ]
  }
}

terraform {
  backend "s3" {
    bucket     = "ifpb"
    key        = "terraform.tfstate"
    region     = "us-east-2"
    access_key = ""
    secret_key = ""
  }
}
