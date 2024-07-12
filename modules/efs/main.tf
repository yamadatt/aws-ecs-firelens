resource "aws_efs_file_system" "efs" {
  tags = {
    Name = "${var.env}-${var.name_prefix}-efs"
  }
}

resource "aws_efs_mount_target" "efs_public1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_container_1a_id
  security_groups = [var.sg_efs_id]
}

resource "aws_efs_mount_target" "efs_public2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_container_1b_id
  security_groups = [var.sg_efs_id]
}




