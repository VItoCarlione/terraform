data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

variable "instance_type" {
  default = "t2.micro"
}

variable "region" {
  default = "us-west-1"
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = "id_rsa.pub"
  user_data = <<EOF
		      #! /bin/bash
          sudo apt-get update
		      sudo apt-get install -y apache2
		      sudo systemctl start apache2
		      sudo systemctl enable apache2
		      echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
}

resource "aws_key_pair" "webserver-key" {
    key_name = "id_rsa.pub"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.web_server.id
  provisioner "local-exec" {
    command = "echo ${aws_eip.eip.public_dns} >> /home/kl/terraform/ec2/web_server_public_dns.txt"
  }
}