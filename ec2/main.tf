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

data "template_file" "user_data" {
  template = "${file("/home/kl/terraform/ec2/install.sh")}"
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
  user_data = "${data.template_file.user_data.rendered}"
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