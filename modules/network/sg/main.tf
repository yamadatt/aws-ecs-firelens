# デフォルトのセキュリティグループのルール削除
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "alb" {
  name        = "${var.env}-${var.name_prefix}-sg-alb"
  description = "Allow http and https traffic."
  vpc_id      = var.vpc_id
  # ここにingressを書かず、ルールはaws_security_group_ruleを使って定義する
}

# 443番ポート許可のインバウンドルール
# resource "aws_security_group_rule" "inbound_https" {
#   type      = "ingress"
#   from_port = 443
#   to_port   = 443
#   protocol  = "tcp"
#   cidr_blocks = [
#     "0.0.0.0/0"
#   ]
#   security_group_id = aws_security_group.alb.id
# }

resource "aws_security_group_rule" "inbound_80" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.alb.id
}


# outbound
resource "aws_security_group_rule" "outbound" {
  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "container" {
  name        = "${var.env}-${var.name_prefix}-sg-container"
  description = "sg container"
  vpc_id      = var.vpc_id

  ingress {
    description = "contanier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.name_prefix}-sg-container"
  }
}

resource "aws_security_group" "vpce" {
  name        = "${var.env}-${var.name_prefix}-sg-vpce"
  description = "sg vpce"
  vpc_id      = var.vpc_id

  ingress {
    description     = "container sg"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.container.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg-vpce"
  }
}




# EC2とEIC Endpointのセキュリティグループ
resource "aws_security_group" "eic_connect" {
  name        = "${var.env}-${var.name_prefix}-eic-sg"
  description = "EIC Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "postgresql"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "dnf-s3"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## EFSのSG

resource "aws_security_group" "efs_sg" {
  name   = "${var.env}-${var.name_prefix}-efs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "maintenance_ec2_sg" {
  name        = "${var.env}-${var.name_prefix}_maintenance_ec2_sg"
  description = "Security group for Maintenance"
  vpc_id      = var.vpc_id
  # タグ
  tags = {
    Name = "${var.env}-${var.name_prefix}_maintenance_ec2_sg"
  }
}

resource "aws_security_group_rule" "inbound_from_office" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = [
    "3.0.5.32/29", # ec2 instance connect for ap-southeast-1
    "192.168.0.0/20",
    "133.203.185.64/32",
    "202.213.157.141/32",
    "202.213.157.129/32",
    "121.1.255.38/32",
    "114.49.34.146/32",
    "116.50.61.180/32"
  ]
  description = "allow ip address"

  security_group_id = aws_security_group.maintenance_ec2_sg.id
}

resource "aws_security_group_rule" "outbound_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound All"
  security_group_id = aws_security_group.maintenance_ec2_sg.id

}



# データベース用のセキュリティグループ
resource "aws_security_group" "db_sg" {
  name        = "${var.env}-${var.name_prefix}-db-sg"
  description = "Security group for Database"
  vpc_id      = var.vpc_id

  # インバウンドルール
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Allow traffic to postgresql"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.3.0/24"]
    description = "Inbound from Maintenance"
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # タグ
  tags = {
    Name = "db_sg01"
  }
}