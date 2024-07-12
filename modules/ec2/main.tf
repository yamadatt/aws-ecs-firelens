resource "aws_instance" "maintenance-ec2" {
  ami                         = "ami-0eb4694aa6f249c52"
  instance_type               = "t3.large"
  subnet_id                   = var.public_subnet_1b02_id
  key_name                    = "key01"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    var.maintenance_ec2_sg_id,
  ]

  root_block_device {
    volume_size           = 400
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.env}-${var.name_prefix}-maintenance-ec2-ebs"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.env}-${var.name_prefix}-maintenance-ec2"
  }
}
