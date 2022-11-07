resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_d" {
  cidr_block        = "10.0.1.0/25"
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = "us-east-1d"

  tags = {
    "Name" = "public | us-east-1d"
  }
}

resource "aws_subnet" "private_d" {
  cidr_block        = "10.0.2.0/25"
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = "us-east-1d"

  tags = {
    "Name" = "private | us-east-1d"
  }
}

resource "aws_subnet" "public_e" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.128/25"
  availability_zone = "us-east-1e"

  tags = {
    "Name" = "public | us-east-1e"
  }
}

resource "aws_subnet" "private_e" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.128/25"
  availability_zone = "us-east-1e"

  tags = {
    "Name" = "private | us-east-1e"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_d_subnet" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_d.id
}

resource "aws_route_table_association" "private_d_subnet" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_e_subnet" {
  subnet_id      = aws_subnet.public_e.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_e_subnet" {
  subnet_id      = aws_subnet.private_e.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_d.id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "HTTPS traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
  }
}

resource "aws_security_group" "amqp" {
  name        = "amqp-tf"
  description = "Allows amqp traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 5671
    protocol    = "TCP"
    to_port     = 5671
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5672
    protocol    = "TCP"
    to_port     = 5672
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nfs" {
  name        = "allow-nfs"
  description = "Allow NFS traffic for mounting EFS volumes"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 2049
    protocol    = "TCP"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }
}



