# ALB用のセキュリティグループ
resource "aws_security_group" "alb_sg01" {
  name        = "alb_sg01"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  # インバウンドルール
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from anywhere"
  }

  # アウトバウンドルール
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic to port 8080 for outbound connections"
  }

  # タグ
  tags = {
    Name = "alb_sg01"
  }
}



