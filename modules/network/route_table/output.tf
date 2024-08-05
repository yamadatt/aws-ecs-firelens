output "route_table_private_1a_id" {
  value = aws_route_table.private_1a.id
}

output "route_table_private_1b_id" {
  value = aws_route_table.private_1b.id
}

output "route_table_rds_1a_id" {
  value = aws_route_table.private_rds_1a.id
}

output "route_table_rds_1b_id" {
  value = aws_route_table.private_rds_1b.id
}


output "route_table_public_1a_id" {
  value = aws_route_table.public_alb_1a.id
}

output "route_table_public_1b_id" {
  value = aws_route_table.public_alb_1b.id
}


