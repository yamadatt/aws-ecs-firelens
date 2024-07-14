output "ecs_task_iam_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_iam_role_exec_arn" {
  value = aws_iam_role.ecs_task_role_exec.arn
}


output "firehose_role_arn" {
  value = aws_iam_role.firehose_role.arn
}

