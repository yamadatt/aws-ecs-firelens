resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.env}-${var.name_prefix}-loudwatch-via-firehose"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "CloudWatch Logs to S3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_to_s3_firehose" {
  name        = "${var.env}-${var.name_prefix}-cloudwatch-to-s3-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = "${var.firehose_role_arn}"
    bucket_arn = aws_s3_bucket.logs_bucket.arn

    buffering_interval = 300    # バッファの時間間隔（秒）
    buffering_size     = 5      # バッファサイズ（MB）
    compression_format = "GZIP" # 圧縮フォーマット
    # cloudwatch_logging_options {
    #   enabled = true
    #   log_group_name = "/ecs/stag-yamada-fluentlog"
    #   log_stream_name = "a"
    # }

  }
}

resource "aws_cloudwatch_log_subscription_filter" "log_subscription_filter" {
  name            = "${var.env}-${var.name_prefix}-subscription-to-s3"
  log_group_name  = "/ecs/${var.env}-${var.name_prefix}-fluentlog"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_to_s3_firehose.arn
  role_arn        = "${var.firehose_role_arn}"

}