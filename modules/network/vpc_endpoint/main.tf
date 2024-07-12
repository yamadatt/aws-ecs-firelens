#------------------------------------------------------------------------------
# コンテナセグメントからS3へのエンドポイント
#------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  tags = {
    Name = "${var.env}-${var.name_prefix}-vpce-s3"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

}

resource "aws_vpc_endpoint_route_table_association" "private_1a" {
  route_table_id  = var.route_table_private_1a_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private_1b" {
  route_table_id  = var.route_table_private_1b_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}


# #------------------------------------------------------------------------------
# # ssmmessages
# #------------------------------------------------------------------------------


# resource "aws_vpc_endpoint" "ssmmessages" {
#   tags = {
#     Name = "${var.env}-${var.name_prefix}-vpce-ssmmessages"
#   }
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-1.ssmmessages"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     var.sg_id
#   ]

#   private_dns_enabled = true
#   subnet_ids = [
#     var.subnet_1a_id,
#     var.subnet_1b_id
#   ]
# }



