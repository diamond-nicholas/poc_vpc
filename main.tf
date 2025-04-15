resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  availability_zone = "${var.aws_region}a"
   map_public_ip_on_launch = true

   tags = {
     Name = "my_subnet"
   }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name= "my_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route  {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name= "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-ec2-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/generated-ec2-key.pem"
  file_permission = "0600"
}


resource "aws_instance" "ec2_block" {
  ami = data.aws_ami.amazon_linux
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
   key_name      = aws_key_pair.generated_key.key_name

   tags = {
     Name = "my_ec2"
   }
}

