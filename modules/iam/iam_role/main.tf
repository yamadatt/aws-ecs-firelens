# タスク起動用IAMロールの定義
resource "aws_iam_role" "ecs_task_role_exec" {
  name = "ecsTasExecRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecsTaskExecRole"
  }
}

# タスク起動用IAMロールへのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_role_exec.name
}


resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# コンテナ用IAMロールの定義
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole-${var.env}-${var.name_prefix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ecs_task_role"
  }
}


# コンテナ用IAMポリシーの定義
resource "aws_iam_policy" "ecs_task" {
  name = "ecsTaskRolePolicy-${var.env}-${var.name_prefix}"
  path = "/service-role/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "firehose:PutRecordBatch"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ]
  })

  tags = {
    Name = "ecsTaskRolePolicy-${var.env}-${var.name_prefix}"
  }
}

# コンテナ用IAMロールへのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_task_attach" {
  policy_arn = aws_iam_policy.ecs_task.arn
  role       = aws_iam_role.ecs_task_role.name
}


# firehoseのロールを定義
# cloudwatchからfirehoseのロールとfirehoseからS3に出力するロールは分けたほうが良いと思う。
# firehose_roleに2つ定義していて、若干見苦しい。
# だが、今回は簡略化のため同じロールを使っている。（動くことを優先した）

resource "aws_iam_role" "firehose_role" {
  name = "${var.env}-${var.name_prefix}-firehose_delivery_role"

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
        "Condition" : {
          "StringLike" : {
            "aws:SourceArn" : "arn:aws:logs:ap-northeast-1:449671225256:*"
          }
        }
      }
    ]
  })
}

# firehoseのロールにポリシーを割り当てる
resource "aws_iam_role_policy_attachment" "firehose_policy_attach" {
  policy_arn = aws_iam_policy.firehose_policy.arn
  role       = aws_iam_role.firehose_role.name
}

resource "aws_iam_policy" "firehose_policy" {
  name = "${var.env}-${var.name_prefix}-firehose_firehose_policy"
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