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
          "logs:DescribeLogStreams"
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