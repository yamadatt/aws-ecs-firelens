###########################################
# EIP
###########################################

resource "aws_eip" "eip" {
  domain = "vpc"  // VPC内でEIPを使用（vpc = trueが使用できなくなるので代わりにこの記述）
  tags = {
    Name = "${var.env}-${var.name_prefix}-ElasticIP-For-NATGW"
  }
}

###########################################
# NAT Gateway
###########################################
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_alb_subnet_1a_id
  tags = {
    Name = "${var.env}-${var.name_prefix}-NAT-GW"
  }
}



