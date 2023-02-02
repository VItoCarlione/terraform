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
}

resource "aws_key_pair" "webserver-key" {
    key_name = "id_rsa.pub"
    public_key = file("~/.ssh/id_rsa.pub")
}