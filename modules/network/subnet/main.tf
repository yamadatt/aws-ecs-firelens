resource "aws_subnet" "public_alb_1a" {

  cidr_block              = var.alb_subnet_cidr_block_1a
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${var.name_prefix}-public-alb-1a"
  }
}

resource "aws_subnet" "public_alb_1b" {

  cidr_block              = var.alb_subnet_cidr_block_1b
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1b
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${var.name_prefix}-public-alb-1b"
  }
}

resource "aws_subnet" "private_container_1a" {
  cidr_block              = var.container_subnet_cidr_block_1a
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1a


  tags = {
    Name = "${var.env}-${var.name_prefix}-private-container-1a"
  }
}

resource "aws_subnet" "private_container_1b" {
  cidr_block              = var.container_subnet_cidr_block_1b
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1b


  tags = {
    Name = "${var.env}-${var.name_prefix}-private-container-1b"
  }
}

resource "aws_subnet" "private_rds_1a" {
  cidr_block              = var.rds_subnet_cidr_block_1a
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1a

  tags = {
    Name = "${var.env}-${var.name_prefix}-private-rds-1a"
  }
}

resource "aws_subnet" "private_rds_1b" {
  cidr_block              = var.rds_subnet_cidr_block_1b
  vpc_id                  = var.vpc_id
  availability_zone       = var.subnet_az_1b

  tags = {
    Name = "${var.env}-${var.name_prefix}-private-rds-1b"
  }
}

