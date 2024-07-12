resource "aws_route_table" "private_1a" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-route-table-1a"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_id
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = var.private_container_subnet_1a_id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table" "private_1b" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-route-table-1b"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gw_id
  }
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = var.private_container_subnet_1b_id
  route_table_id = aws_route_table.private_1b.id
}

resource "aws_route_table" "public_alb_1a" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-public-alb-route-table-1a"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "public_alb_1a" {
  subnet_id      = var.public_alb_subnet_1a_id
  route_table_id = aws_route_table.public_alb_1a.id
}

resource "aws_route_table" "public_alb_1b" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-public-alb-route-table-1b"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "public_alb_1b" {
  subnet_id      = var.public_alb_subnet_1b_id
  route_table_id = aws_route_table.public_alb_1b.id
}

###########################################
# RDS用のルートテーブル
###########################################

resource "aws_route_table" "private_rds_1a" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-rds-route-table-1a"
  }
}

resource "aws_route_table_association" "private_rds_1a" {
  subnet_id      = var.private_rds_subnet_1a_id
  route_table_id = aws_route_table.private_rds_1a.id
}

resource "aws_route_table" "private_rds_1b" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-rds-route-table-1b"
  }
}

resource "aws_route_table_association" "private_rds_1b" {
  subnet_id      = var.private_rds_subnet_1b_id
  route_table_id = aws_route_table.private_rds_1b.id
}

