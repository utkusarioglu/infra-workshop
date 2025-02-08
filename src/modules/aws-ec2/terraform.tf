resource "aws_vpc" "tiger" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

resource "aws_subnet" "cat" {
  cidr_block        = cidrsubnet(aws_vpc.tiger.cidr_block, 2, 0)
  vpc_id            = aws_vpc.tiger.id
  availability_zone = var.availability_zone
  tags              = var.tags
}

resource "aws_internet_gateway" "gator" {
  vpc_id = aws_vpc.tiger.id
}

resource "aws_route_table" "kitty" {
  vpc_id = aws_vpc.tiger.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gator.id
  }
}

resource "aws_route_table_association" "cat_kitty" {
  subnet_id      = aws_subnet.cat.id
  route_table_id = aws_route_table.kitty.id
}

resource "aws_security_group" "gorilla" {
  name   = "gorilla"
  vpc_id = aws_vpc.tiger.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}

data "aws_ami" "lion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bird" {
  ami                         = data.aws_ami.lion.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.butterfly.key_name
  security_groups             = [aws_security_group.gorilla.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cat.id
  monitoring                  = true
  user_data                   = file("user-data.aws.sh")
  tags                        = var.tags

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.003"
    }
  }
}

resource "tls_private_key" "fox" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "butterfly" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.fox.public_key_openssh
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.fox.private_key_pem
  filename = local.ssh_private_key_abspath
}

resource "null_resource" "ssh_private_key_chmod" {
  depends_on = [local_file.ssh_private_key]

  provisioner "local-exec" {
    command = "chmod 600 ${local.ssh_private_key_abspath}"
  }
}
