output "sg_vpce_id" {
  value = aws_security_group.vpce.id
}

output "sg_eic_connect_id" {
  value = aws_security_group.eic_connect.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_container_id" {
  value = aws_security_group.container.id
}

output "sg_efs_id" {
  value = aws_security_group.efs_sg.id
}

output "maintenance_ec2_sg_id" {
  value = aws_security_group.maintenance_ec2_sg.id
}

output "db_sg01_id" {
  value = aws_security_group.db_sg.id
}



# output "sg_rds_id" {
#   value = aws_security_group.rds.id
# }

