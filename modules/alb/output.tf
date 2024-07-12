output "alb_tg_mars_g_c_arn" {
  value = aws_lb_target_group.this.arn
}

output "alb_tg_mars_g_c_name" {
  value = aws_lb_target_group.this.name
}

output "alb_listener_mars_g_c_arn_https" {
  value = aws_lb_listener.this.arn
}

output "aws_lb_target_group_mars_g_c_arn_suffix" {
  value = aws_lb_target_group.this.arn_suffix
}
output "aws_lb_alb_arn_suffix" {
  value = aws_lb.alb.arn_suffix
}

output "aws_lb_target_group_mars_g_c_id" {
  value = aws_lb_target_group.this.id
}
output "aws_lb_alb_id" {
  value = aws_lb.alb.id
}



