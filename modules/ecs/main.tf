resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.name_prefix}-ecs"

  tags = {
    Name = "${var.env}-${var.name_prefix}-ecs"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env}-${var.name_prefix}-nginx-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = var.ecs_task_iam_role_arn
  execution_role_arn       = var.ecs_task_iam_role_exec_arn
  track_latest = true
  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "public.ecr.aws/nginx/nginx:stable-alpine3.19-slim"

      LogConfiguration = {
        LogDriver = "awsfirelens"
        Options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.env}-${var.name_prefix}-nginx"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name              = "log_router",
      image             = "public.ecr.aws/aws-observability/aws-for-fluent-bit:init-latest",
      cpu               = 0,
      memoryReservation = 50,
      portMappings      = [],
      essential         = true,
      
      environment = [
        {
            name = "aws_fluent_bit_init_s3_1",
            value = "arn:aws:s3:::fluent-bit-yamada/extra.conf" 
        }
    ],

      logConfiguration = {
        logDriver = "awslogs", # fluentbit自体のログはCloudWatch logsに出力
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/${var.env}-${var.name_prefix}-fluentlog",
          awslogs-region        = "ap-northeast-1",
          awslogs-stream-prefix = "ecs"
        },
      },
      firelensConfiguration = {
        type = "fluentbit"
      }
    }



  ])


}

# data "aws_ecs_task_definition" "this" {
#   task_definition = aws_ecs_task_definition.this.family
# }

resource "aws_ecs_service" "this" {
  name                   = "${var.env}-${var.name_prefix}-nginx-service"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.backend_desired_count
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    security_groups = [var.sg_container_id]
    subnets = [
      var.subnet_container_1a_id,
      var.subnet_container_1b_id
    ]
  }

  load_balancer {
    target_group_arn = var.alb_tg_mars_g_c_arn
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.env}-${var.name_prefix}-nginx"
  retention_in_days = "7"
}

