resource "aws_ssm_parameter" "root_password" {
  name  = "/myapp/root-password"
  type  = "SecureString"
  value = "password"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name = "ec2_ssm_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ssm:GetParameter",
        Resource = aws_ssm_parameter.root_password.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "maintenance" {
  ami                         = "ami-0b9593848b0f1934e"
  instance_type               = "t3.nano"
  subnet_id                   = var.public_subnet_1a_id
  key_name                    = "radio"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    var.maintenance_ec2_sg_id,
  ]


  user_data = <<-EOF
              #!/bin/bash
              # Install AWS CLI
              yum update -y
              yum install -y aws-cli

              # Get the root password from Parameter Store
              ROOT_PASSWORD=$(aws ssm get-parameter --name "/myapp/root-password" --with-decryption --query "Parameter.Value" --output text --region ap-northeast-1")

              # Set the root password
              echo "root:$ROOT_PASSWORD" | chpasswd
              EOF

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name


  root_block_device {
    volume_size           = 8
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

