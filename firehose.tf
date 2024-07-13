resource "aws_s3_bucket" "logs_bucket" {
  bucket = "cloudwatch-via-firehose-yamada"
  

  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "CloudWatch Logs to S3"
  }
}



resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.ap-northeast-1.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        "Condition": { 
           "StringLike": { 
             "aws:SourceArn": "arn:aws:logs:ap-northeast-1:449671225256:*"
           } 
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "firehose:PutRecord"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_to_s3_firehose" {
  name        = "cloudwatch-to-s3-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.logs_bucket.arn

    buffering_interval = 300 # バッファの時間間隔（秒）
    buffering_size     = 5   # バッファサイズ（MB）
    compression_format = "GZIP" # 圧縮フォーマット
    # cloudwatch_logging_options {
    #   enabled = true
    #   log_group_name = "/ecs/stag-yamada-fluentlog"
    #   log_stream_name = "a"
    # }

  }
}

resource "aws_cloudwatch_log_subscription_filter" "log_subscription_filter" {
  name            = "example-subscription"
  log_group_name  = "/ecs/stag-yamada-fluentlog"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_to_s3_firehose.arn
  role_arn        = aws_iam_role.firehose_role.arn

}