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

# Done
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
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

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

data "aws_route53_zone" "domain" {
  name = "utkusarioglu.com."
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "vanilla.${data.aws_route53_zone.domain.name}"
  type    = "A"
  ttl     = 3600
  records = [aws_instance.bird.public_ip]
}

# Done
resource "aws_s3_bucket" "files" {
  bucket = local.bucket
}

# Done
resource "aws_s3_bucket_ownership_controls" "private_bucket_ownership" {
  bucket = aws_s3_bucket.files.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# Done
resource "aws_s3_bucket_acl" "private_bucket_acl" {
  bucket = aws_s3_bucket.files.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.private_bucket_ownership]
}

# Done
resource "aws_s3_bucket_policy" "private_bucket_policy" {
  bucket = aws_s3_bucket.files.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.files.id}",
          "arn:aws:s3:::${aws_s3_bucket.files.id}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_s3_read_role.arn
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.files.id}/*"
      }
    ]
  })
}


resource "aws_s3_object" "my_file" {
  bucket = aws_s3_bucket.files.id
  key    = "index.html" # Path in the bucket
  source = "index.html" # Local file to upload
}

# Done
resource "aws_iam_role" "ec2_s3_read_role" {
  name = "ec2_s3_read_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Done
resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3_read_policy"
  description = "Allow EC2 to read from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.files.id}/*"
      }
    ]
  })
}

# Done
resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.ec2_s3_read_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Done
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_read_role.name
}
