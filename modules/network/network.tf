resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc01"
  }
}

resource "aws_subnet" "public_subnet_1a01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "public_subnet_1a01"
  }
}

resource "aws_subnet" "public_subnet_1b01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "public_subnet_1b01"
  }
}

resource "aws_subnet" "public_subnet_1b02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "public_subnet_1b02"
  }
}

resource "aws_subnet" "private_subnet_1a01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.5.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "private_subnet_1a01"
  }
}

resource "aws_subnet" "private_subnet_1b01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.6.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "private_subnet_1b01"
  }
}

resource "aws_subnet" "private_subnet_1a02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.7.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "private_subnet_1a02"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public_route_table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "public_subnet_1a01_association" {
  subnet_id      = aws_subnet.public_subnet_1a01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_1b01_association" {
  subnet_id      = aws_subnet.public_subnet_1b01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_1b02_association" {
  subnet_id      = aws_subnet.public_subnet_1b02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_subnet_1a01_association" {
  subnet_id      = aws_subnet.private_subnet_1a01.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_1b01_association" {
  subnet_id      = aws_subnet.private_subnet_1b01.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_1a02_association" {
  subnet_id      = aws_subnet.private_subnet_1a02.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1a01.id

  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}